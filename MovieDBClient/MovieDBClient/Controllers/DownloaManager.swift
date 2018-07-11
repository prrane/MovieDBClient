//
//  MoviePosterDownloader.swift
//  MovieDBClient
//
//  Created by Prashant Rane.
//

import Foundation

class DownloaManager: NSObject {

  // KVO
  private var kDownloaManagerContext = 1
  private var refreshCallback: (() -> Void)?

  private let posterDownloadManager = MoviePosterDownloadManager()
  private let searchManager = SearchManager()

  func setup(with refreshCallback: Callback) {
    self.refreshCallback = refreshCallback
  }

  override init() {
    super.init()

    CacheManager.searchResultsCache.addObserver(self, forKeyPath:#keyPath(SearchResultsCache.isUpdated), options: .new, context: &kDownloaManagerContext)

    CacheManager.moviePosterCache.addObserver(self, forKeyPath:#keyPath(MoviePosterCache.isUpdated), options: .new, context: &kDownloaManagerContext)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kDownloaManagerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    guard keyPath == #keyPath(MoviePosterCache.isUpdated) || keyPath == #keyPath(SearchResultsCache.isUpdated) else {
      return
    }

    DispatchQueue.main.async { [weak self] in
      self?.posterDownloadManager.okToProceed = true
      self?.refreshCallback?()
    }
  }

  func downloadPoster(for movie: Movie) {
    posterDownloadManager.downloadMoviePoster(for: movie)
  }

  func search(keyword: String) {
    posterDownloadManager.cancelAllOperations()
    searchManager.keyword = keyword
  }

  func getNextPage() {
    searchManager.getNextpage()
  }
}
