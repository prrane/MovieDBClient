//
//  SearchController.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 10/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import Foundation

class SearchController: NSObject {

  // KVO
  private var kSearchControllerContext = 1
  private var refreshCallback: (() -> Void)?
  let searchManager = SearchManager()

  func setup(with refreshCallback: Callback) {
    self.refreshCallback = refreshCallback
  }

  override init() {
    super.init()

    CacheManager.searchResultsCache.addObserver(self, forKeyPath:#keyPath(SearchResultsCache.isUpdated), options: .new, context: &kSearchControllerContext)
  }
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard context == &kSearchControllerContext else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    guard keyPath == #keyPath(SearchResultsCache.isUpdated) else {
      return
    }

    DispatchQueue.main.async { [weak self] in
      self?.refreshCallback?()
    }
  }

  func search(keyword: String) {
    searchManager.keyword = keyword
  }
  
}
