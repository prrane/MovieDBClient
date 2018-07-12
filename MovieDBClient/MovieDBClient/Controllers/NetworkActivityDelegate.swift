//  NetworkActivityDelegate.swift
//
//  Created by Prashant Rane.
//

import Foundation

class NetworkActivityDelegate: NSObject {

  // KVO
  private var kDownloaManagerContext = 1
  private var refreshCallback: ((Bool) -> Void)?

  private let posterDownloadManager = MoviePosterDownloadManager()
  private let searchManager = MovieSearchManager()

  func setup(with refreshCallback: ((Bool) -> Void)?) {
    self.refreshCallback = refreshCallback
  }

  override init() {
    super.init()

    CacheManager.searchResultsCache.addObserver(self, forKeyPath:#keyPath(SearchResultsCache.state), options: .new, context: &kDownloaManagerContext)

    CacheManager.moviePosterCache.addObserver(self, forKeyPath:#keyPath(MoviePosterCache.state), options: .new, context: &kDownloaManagerContext)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kDownloaManagerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    if keyPath == #keyPath(MoviePosterCache.state), let cache = object as? MoviePosterCache {
      DispatchQueue.main.async { [weak self] in
        self?.refreshCallback?(false)
      }
    }
    else if keyPath == #keyPath(SearchResultsCache.state), let cache = object as? SearchResultsCache {
      DispatchQueue.main.async { [weak self] in
        switch cache.state {
        case .cleared: self?.refreshCallback?(true)
        case .itemCached:
          self?.posterDownloadManager.okToProceed = true
          self?.refreshCallback?(false)
        }
      }
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
