//
//  MoviePosterDownloadOperation.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 10/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MoviePosterDownloadOperation: AsyncOperation {

  let posterDownloadURL: URL
  let movieId: Int

  init(with movieId: Int, posterDownloadURL: URL)  {
    self.movieId = movieId
    self.posterDownloadURL = posterDownloadURL
  }

  override func start() {
    print("Download: Operation Started for \(movieId)")

    guard !self.isCancelled else {
      print("Download: Marked as finished because it is cancelled for \(movieId)")
      self.state = .finished
      return
    }

    state = .executing
    execute()
  }

  private func execute() {

    URLSession.shared.dataTask(with: posterDownloadURL) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
      self?.state = .finished
      print("Download: Operation finished for \(String(describing: self?.movieId))")

      guard error == nil else {
        return
      }

      guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
        return
      }

      guard statusCode >= 200 && statusCode < 300 else {
        return
      }

      guard let posterData = data else {
        return
      }

      guard let strongSelf = self else {
        return
      }

      CacheManager.moviePosterCache.add(moviePoster: UIImage(data: posterData), with: strongSelf.movieId)
      
      }.resume()

  }

}
