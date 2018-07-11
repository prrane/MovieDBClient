//
//  Models.swift
//  MovieDBClient
//
//  Created by Prashant Rane.
//

import Foundation

/**
 `APIResponse->response` Sample data
  "title": "Batman",
  "id": 268,
  "release_date": "1989-06-23",
  "overview": "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker",
  "poster_path": "\/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg"
  */

public class Movie: NSObject, Codable {

  let title: String
  let id: Int
  let releaseDate: String
  let overview: String
  let posterPath: String? // this is optional as per API Docs

  public required init?(coder aDecoder: NSCoder) {
    title = aDecoder.decodeObject(forKey: CodingKeys.title.description) as! String
    id = aDecoder.decodeInteger(forKey: CodingKeys.id.description)
    releaseDate = aDecoder.decodeObject(forKey: CodingKeys.releaseDate.description) as! String
    overview = aDecoder.decodeObject(forKey: CodingKeys.overview.description) as! String
    posterPath = aDecoder.decodeObject(forKey: CodingKeys.posterPath.description) as? String
  }

  //https://image.tmdb.org/t/p/w92/2DtPSyODKWXluIRV7PVru0SSzja.jpg
  public var posterDownloadURL: URL? {
    guard let path = posterPath else {
      return nil
    }

    return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
  }
  
  public override var description: String {
    guard let posterPath = posterPath else {
      return "\(title) : \(id) : NO_POSTER_AVAILABLE"
    }
    
    return "\(title) : \(id) : \(posterPath)"
  }

}

/**
 `APIResponse` Sample Data
   "page": 1000,
   "total_results": 106,
   "total_pages": 6,
   "results": []

      OR

   "status_code": 7,
   "status_message": "Invalid API key: You must be granted a valid key.",
   "success": false

    OR

  "errors": ["query must be provided"]
 */

public enum APIError {
  case success
  case error(message: String)
}

public class APIResponse: NSObject & Codable {
  // Success
  let currentPage: Int  // Starts from `1`
  let totalResults: Int
  let totalPages: Int
  let movies: [Movie]

  // Error
  let statusMessage: String?
  let success: Bool?
  let errors: [String]?

  var apiError: APIError {
    var hasError = !(success ?? true)
    hasError = hasError || !((errors ?? []).isEmpty)
    let errorMessage = statusMessage ?? errors?.joined(separator: "\n") ?? NSLocalizedString("Something went wrong, please try later", comment: "Generic error message")

    return hasError ? .error(message: errorMessage) : .success
  }

  private enum CodingKeys: String, CodingKey {
    // Success
    case currentPage = "page"
    case totalResults
    case totalPages
    case movies = "results"

    // Error
    case statusMessage
    case success
    case errors
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let currentPage = try? container.decode(Int.self, forKey: .currentPage)
    self.currentPage = currentPage ?? 0
    let totalResults = try? container.decode(Int.self, forKey: .totalResults)
    self.totalResults = totalResults ?? 0
    let totalPages = try? container.decode(Int.self, forKey: .totalPages)
    self.totalPages = totalPages ?? 0
    let movies = try? container.decode([Movie].self, forKey: .movies)
    self.movies = movies ?? []

    statusMessage = try? container.decode(String.self, forKey: .statusMessage)
    success = try? container.decode(Bool.self, forKey: .success)
    errors = try? container.decode([String].self, forKey: .errors)
  }

}
