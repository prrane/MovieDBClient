//
//  CacheManager.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit
import PINCache

// MARK: Cache interfaces

public protocol KeywordCache {
  func add(keyword: String)
  var keywords: [String] { get }
}

@objc public protocol SearchResultsCache {
  func add(results: APIResponse)
  func movies(forSection section: Int) -> [Movie]
  func shouldPrefetch(forSection section: Int) -> Bool
  func item(forIndexPath indexPath: IndexPath) -> Movie?

  var numberOfSections: Int { get }
  var isUpdated: Bool { get }
  func clearCache()
}

@objc public protocol MoviePosterCache {
  func moviePoster(for movieId: Int) -> UIImage?
  func add(moviePoster poster: UIImage?, with movieId: Int)
  func clearCache()

  var isUpdated: Bool { get }
}

// MARK: Cache Facade

class CacheManager {
  public static let keywordCache: KeywordCache = KeywordCacheManager.shared
  public static let searchResultsCache: NSObject & SearchResultsCache = SearchResultsCacheManager.shared
  public static let moviePosterCache: NSObject & MoviePosterCache = MoviePosterCacheManager.shared
}

// MARK: - KeywordCacheManager

@objc(KeywordEntry) private final class KeywordEntry: NSObject, NSCoding {
  var keyword: String = ""
  var entryTime: Date

  init(keyword: String, entryTime: Date) {
    self.keyword = keyword
    self.entryTime = entryTime
  }

  func encode(with aCoder: NSCoder) {
    aCoder.encode(keyword, forKey: "keyword")
    aCoder.encode(entryTime, forKey: "entryTime")
  }

  required init?(coder aDecoder: NSCoder) {
    keyword = aDecoder.decodeObject(forKey: "keyword") as? String ?? ""
    entryTime = aDecoder.decodeObject(forKey: "entryTime") as? Date ?? Date.distantPast
  }

}

private final class KeywordCacheManager: KeywordCache {

  static let shared = KeywordCacheManager()

  private struct Constants {
    static let maxKeywordCount: Int = 10
    static let cacheKey = "KeywordCache"

    static let cacheAgeLimit: TimeInterval = 7 * 60 * 60 * 24   // Cache for 7 days in seconds
    static let cacheSize: UInt = 1 * 1024 * 1024             // Max 1 MB disk cache
  }

  private let cache: PINCache = {
    let cache = PINCache(name: Constants.cacheKey)
    cache.diskCache.byteLimit = Constants.cacheSize
    cache.diskCache.ageLimit = Constants.cacheAgeLimit
    return cache
  }()

  public var keywords: [String] {
    var cacheEntries = entries
    cacheEntries.sort(by: { $0.entryTime > $1.entryTime })
    return cacheEntries.map{ $0.keyword }
  }

  public func add(keyword: String) {
    var cacheEntries = entries
    let entry = KeywordEntry(keyword: keyword, entryTime: Date())

    let existingEntries = cacheEntries.filter { $0.keyword == keyword }
    if let entry = existingEntries.first, let index = cacheEntries.index(of: entry) {
      cacheEntries.remove(at: index)
    }

    if cacheEntries.count >= Constants.maxKeywordCount {
      purgeLastKeyword()
    }

    cache[Constants.cacheKey] =  cacheEntries + [entry]
  }

  // MARK: Internal

  private func purgeLastKeyword() {
    var cacheEntries = entries
    cacheEntries.sort(by: { $0.entryTime > $1.entryTime })
    cacheEntries.removeLast()
    cache[Constants.cacheKey] = cacheEntries
  }

  private var entries: [KeywordEntry] {
    return cache[Constants.cacheKey] as? [KeywordEntry] ?? []
  }
}

// MARK: - SearchResultsCacheManager

private final class SearchResultsCacheManager: NSObject, SearchResultsCache {
  static let shared = SearchResultsCacheManager()
  private let queue = DispatchQueue(label: "com.prrane.movie-db.searchResultsCache")
  //[PageNumber: APIResponse]
  private var cache = [Int: APIResponse]()
  private var mostRecentSearchResults: APIResponse?

  var numberOfSections: Int {
    return cache.keys.count
  }
  
  func add(results: APIResponse) {
    cache[results.currentPage] = results
    mostRecentSearchResults = results
    isUpdated = true
  }

  func movies(forSection section: Int) -> [Movie] {
    let page = section + 1
    guard numberOfSections >= page else {
      return []
    }

    return cache[page]?.movies ?? []
  }

  func shouldPrefetch(forSection section: Int) -> Bool {
    guard let recent = mostRecentSearchResults else {
      return true
    }

    let page = section + 1
    if page <= recent.currentPage {
      return false
    }

    if recent.currentPage == recent.totalPages {
      return false
    }

    return true
  }

  func item(forIndexPath indexPath: IndexPath) -> Movie? {
    let movies = self.movies(forSection: indexPath.section)
    guard indexPath.row < movies.count else {
      return nil
    }

    return movies[indexPath.row]
  }

  func clearCache() {
    cache.removeAll()
    isUpdated = true
  }

  @objc open dynamic var isUpdated: Bool = false {
    willSet {
      willChangeValue(forKey: "isUpdated")
    }
    didSet {
      didChangeValue(forKey: "isUpdated")
    }
  }
}

// MARK: - MoviePosterCacheManager

private final class MoviePosterCacheManager: NSObject,  MoviePosterCache {

  static let shared = MoviePosterCacheManager()

  private struct Constants {
    static let imageCacheAgeLimit: TimeInterval = 30 * 60 * 60 * 24            // Cache for 30 days in seconds
    static let maxImageMemoryCostLimit: UInt = 30 * 1024 * 1024                // Max 30 MB RAM
    static let maxImageCacheSize: UInt = 4 * Constants.maxImageMemoryCostLimit // Max 4 times RAM cache
    static let imageCacheKey = "PosterImageCache"
  }

  private let imageCache: PINCache = {
    let cache = PINCache(name: Constants.imageCacheKey)
    cache.diskCache.byteLimit = Constants.maxImageCacheSize
    cache.diskCache.ageLimit = Constants.imageCacheAgeLimit
    cache.memoryCache.costLimit = Constants.maxImageMemoryCostLimit
    return cache
  }()

  func clearCache() {
    imageCache.removeAllObjects()
  }

  // Using synchronus calls, as the image size is small and good RAM cache is available
  func moviePoster(for movieId: Int) -> UIImage? {
    return imageCache.object(forKey: "\(movieId)") as? UIImage
  }

  func add(moviePoster poster: UIImage?, with movieId: Int) {
    guard let image = poster else {
      return
    }

    imageCache.setObject(image, forKey: "\(movieId)")
    isUpdated = true
  }

  @objc open dynamic var isUpdated: Bool = false {
    willSet {
      willChangeValue(forKey: "isUpdated")
    }
    didSet {
      didChangeValue(forKey: "isUpdated")
    }
  }
}

extension Sequence where Iterator.Element: Equatable {
  func unique() -> [Iterator.Element] {
    return reduce([], { collection, element in collection.contains(element) ? collection : collection + [element] })
  }
}

