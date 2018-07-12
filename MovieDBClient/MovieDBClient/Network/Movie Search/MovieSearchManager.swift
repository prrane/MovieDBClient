//  SearchManager.swift
//
//  Created by Prashant Rane.
//

import Foundation

class MovieSearchManager: NSObject {

  struct Constants {
    static let errorNotificationKey = "SearchOperationError"
    static let errorMessageKey = "SearchOperationErrorMessage"
  }

  private let queue = AsyncQueue(named: "com.prrane.movie-db.search")
  private var kSearchManagerContext = 1

  var keyword: String = "" {
    didSet {
      print("Now searching for: \(keyword)")
      resetAndRestart()
    }
  }

  var currentPage: Int

  private var nextPage: Int {
    return currentPage + 1
  }

  override init() {
    currentPage = 1
  }

  func getNextpage() {
    currentPage = nextPage
    print("Fetching page: \(currentPage) | next : \(nextPage)")
    restart()
  }

  private func reset() {
    currentPage = 1
    queue.cancelAllOperations()
    CacheManager.searchResultsCache.clearCache()
  }

  private func restart() {
    let operation = MovieSearchOperation(with: keyword, page: currentPage)
    operation.addObserver(self, forKeyPath: #keyPath(MovieSearchOperation.state), options: .new, context: &kSearchManagerContext)

    queue.addOperation(operation)
  }

  private func resetAndRestart() {
    reset()
    restart()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kSearchManagerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    guard let operation = object as? MovieSearchOperation else {
      return
    }

    guard keyPath == #keyPath(MovieSearchOperation.state) else {
      return
    }

    guard let newValue = change?[NSKeyValueChangeKey.newKey] as? Int, newValue == AsyncOperation.State.finished.rawValue else {
      return
    }

    if let errorMessage = operation.errorMessage {
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.errorNotificationKey), object: nil, userInfo: [Constants.errorMessageKey : errorMessage])
      }
    }

    // Remove observer
    operation.removeObserver(self, forKeyPath: #keyPath(MovieSearchOperation.state))
  }

}
