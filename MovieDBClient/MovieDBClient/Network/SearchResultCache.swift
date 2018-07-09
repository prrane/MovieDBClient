//
//  SearchResultCache.swift
//  FlickrWall
//
//  Created by Prashant Rane on 01/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import Foundation

//MARK: - Properties

class SearchResultsCache: NSObject {

  static let shared = SearchResultsCache()

  //[PageNumber: SearchResults]
  private var cache = [Int: SearchResults]()
  private var mostRecentSearchResults: SearchResults?

  @objc open dynamic var isUpdated: Bool = false {
    willSet {
      willChangeValue(forKey: "isUpdated")
    }
    didSet {
      didChangeValue(forKey: "isUpdated")
    }
  }

  func invalidateCache() {
    cache.removeAll()
    isUpdated = true
  }

  func add(results: SearchResults) {
    cache[results.currentPage] = results
    mostRecentSearchResults = results
    isUpdated = true
  }

  func searchResults(for page:Int) -> SearchResults? {
    return cache[page]
  }

  func numberOfPages() -> Int {
    return cache.keys.count
  }

  func shouldPredetch(forPage page: Int) -> Bool {
    guard let recent = mostRecentSearchResults else {
      return true
    }

    if page <= recent.currentPage {
      return false
    }

    if recent.currentPage == recent.totalPages {
      return false
    }

    return true
  }

  func item(forIndexPath indexPath: IndexPath) -> Photo? {
    guard let searchResult = searchResults(for: indexPath.section + 1) else {
      return nil
    }

    guard indexPath.row < searchResult.photos.count else {
      return nil
    }

    return searchResult.photos[indexPath.row]
  }

  func numberOfPhotos(for page: Int) -> Int {
    return cache[page]?.photos.count ?? 0
  }

}
