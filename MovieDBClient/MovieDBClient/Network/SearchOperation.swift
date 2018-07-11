//
//  SearchOperation.swift
//  FlickrWall
//
//  Created by Prashant Rane.
//

import Foundation

class SearchOperation: AsyncOperation {

  let currentPage: Int
  let keyword: String
  var errorMessage: String?
  var movies = [Movie]()

  init(with keyword: String, page: Int = 1)  {
    self.keyword = keyword
    self.currentPage = page
  }

  override func start() {
    print("Search: Operation Started for \(keyword)")

    guard !self.isCancelled else {
      print("Search: Marked as finished because it is cancelled for \(keyword)")
      self.state = .finished
      return
    }

    state = .executing
    execute()
  }

  private func execute() {
    fetchMovies(for: keyword, page: currentPage) { [weak self] (keyword: String, response: APIResponse?, error: String?) in

      guard error == nil else {
        self?.errorMessage = "Error while searching: \(error!)"
        self?.state = .finished
        return
      }

      guard response != nil else {
        self?.errorMessage = "Failed to get response from server, please try later"
        self?.state = .finished
        return
      }

      switch response!.apiError {
      case .success:
        print("Success: we got valid response from server")
      case .error(let message):
        self?.errorMessage = message
        self?.state = .finished
        return
      }

      guard let movies = response?.movies, !movies.isEmpty else {
        self?.errorMessage = "No search results returned for keyword: \(keyword)"
        self?.state = .finished
        return
      }

      print("Fetched movies [\(movies.count)]: current page: \(response!.currentPage), total pages: \(response!.totalPages) \n")

      CacheManager.keywordCache.add(keyword: keyword)
      CacheManager.searchResultsCache.add(results: response!)
      print(response!.movies)

      self?.state = .finished
    }
  }

}

//MARK: - Download Helpers
extension SearchOperation {

  // Prepate the search request
  //  http://api.themoviedb.org/3/search/movie?api_key=2696829a81b1b5827d515ff121700838&query=batman&page=1
  private func movieDBRequest(for keyword: String, page: Int = 1) -> URLRequest? {
    let queryItems = [
      URLQueryItem(name: "api_key", value: "2696829a81b1b5827d515ff121700838"),
      URLQueryItem(name: "query", value: keyword),
      URLQueryItem(name: "page", value: "\(page)"),
    ]

    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.themoviedb.org"
    components.path = "/3/search/movie"
    components.queryItems = queryItems

    guard let url = components.url else {
      return nil
    }

    return URLRequest(url: url)
  }

  private func fetchMovies(for keyword: String, page: Int, completion: @escaping (_ keyword: String, _ response: APIResponse?, _ error: String?) -> Void) {

    guard let urlRequest = movieDBRequest(for: keyword, page: page) else {
      return
    }

    URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
      guard error == nil else {
        completion(keyword, nil, error!.localizedDescription)
        return
      }

      guard let data = data else {

        // For a few error status code, we get Error in `data`
        // If we do not get data, let's catch error status code
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
          completion(keyword, nil, "Failed to get response from server, please try later")
          return
        }

        guard statusCode >= 200 && statusCode < 300 else {
          completion(keyword, nil, "Server request failed, please try later")
          return
        }

        completion(keyword, nil, "Failed to get movie data from server, please try later")
        return
      }

      do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(APIResponse.self, from: data)
        completion(keyword, apiResponse, nil)
      }
      catch let error {
        print(error)
        completion(keyword, nil, error.localizedDescription)
      }

      }.resume()
  }

}
