//  MoviePosterDownloadManager.swift
//
//  Created by Prashant Rane.
//

import Foundation

class MoviePosterDownloadManager: NSObject {

  private var kMoviePosterDownloadManagerContext = 1

  private let downloadQueue = AsyncQueue(named: "com.prrane.movie-db.poster.download", maxConcurrentOperationCount: 5)

  private let dictionaryQueue = DispatchQueue(label: "com.prrane.movie-db.poster.download.dictionary")

  private var movieIdToDownloadOperationsMap = [Int: MoviePosterDownloadOperation]()

  // Used to start/stop downloading

  var okToProceed = false

  func cancelAllOperations() {
    downloadQueue.cancelAllOperations()
    okToProceed = false
  }

  func downloadMoviePoster(for movie: Movie) {
    guard okToProceed else {
      print("Not ok to proceed photo download")
      return
    }

    var isDownloadForProvidedMoviePosterModelInProgress = false
    dictionaryQueue.sync {
      let filteredOperations = movieIdToDownloadOperationsMap.keys.filter { $0 == movie.id }
      isDownloadForProvidedMoviePosterModelInProgress = !filteredOperations.isEmpty
    }

    guard !isDownloadForProvidedMoviePosterModelInProgress else {
      print("The Movie Poster \(movie.id) download is already in progress")
      return
    }

    guard let url = movie.posterDownloadURL else {
      print("Could not generate url for model: \(movie) ")
      return
    }

    let downloadOperation = MoviePosterDownloadOperation(with: movie.id, posterDownloadURL: url)
    downloadOperation.addObserver(self, forKeyPath: #keyPath(MoviePosterDownloadOperation.state), options: .new, context: &kMoviePosterDownloadManagerContext)
    downloadQueue.addOperation(downloadOperation)

    dictionaryQueue.sync {
      movieIdToDownloadOperationsMap[movie.id] = downloadOperation
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kMoviePosterDownloadManagerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    guard let downloaOperation = object as? MoviePosterDownloadOperation else {
      return
    }

    guard keyPath == #keyPath(MoviePosterDownloadOperation.state) else {
      return
    }

    guard let newValue = change?[NSKeyValueChangeKey.newKey] as? Int, newValue == AsyncOperation.State.finished.rawValue else {
      return
    }

    // Remove operation
    downloaOperation.removeObserver(self, forKeyPath: #keyPath(MoviePosterDownloadOperation.state))
    dictionaryQueue.sync {
      movieIdToDownloadOperationsMap.removeValue(forKey: downloaOperation.movieId)
      print("Pending Photo Downloads: \(movieIdToDownloadOperationsMap.keys.count)")
    }
  }

}
