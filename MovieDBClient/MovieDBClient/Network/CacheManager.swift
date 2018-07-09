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

public protocol SearchResultsCache {
  func add(results: [Movie])
  var movies: [Movie] { get }

  func clearCache()
}

public protocol MoviePosterCache {
  func moviePoster(forPath path: String, callback:@escaping (_ key: String, _ poster: UIImage?) -> Void)
  func add(moviePoster poster: UIImage?, with path: String)
}

// MARK: Cache Facade

class CacheManager {
  public static let keywordCache: KeywordCache = KeywordCacheManager.shared
  public static let searchResultsCache: SearchResultsCache = SearchResultsCacheManager.shared
  public static let moviePosterCache: MoviePosterCache = MoviePosterCacheManager.shared
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
    static let maxKeywordCount: Int = 3
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
    let cacheEntries = entries
    let entry = KeywordEntry(keyword: keyword, entryTime: Date())

    if !cacheEntries.contains(entry), cacheEntries.count >= Constants.maxKeywordCount {
      purgeLastKeyword()
    }

    cache[Constants.cacheKey] =  entries + [entry]
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

private final class SearchResultsCacheManager: SearchResultsCache {
  static let shared = SearchResultsCacheManager()
  private let queue = DispatchQueue(label: "com.prrane.movie-db.searchResultsCache")
  public private(set) var movies = [Movie]()

  func add(results: [Movie]) {
    movies.append(contentsOf: results)
  }

  func clearCache() {
    movies = []
  }
}

// MARK: - MoviePosterCacheManager

private final class MoviePosterCacheManager: MoviePosterCache {

  static let shared = MoviePosterCacheManager()

  private struct Constants {
    static let imageCacheAgeLimit: TimeInterval = 30 * 60 * 60 * 24   // Cache for 30 days in seconds
    static let maxImageMemoryCostLimit: UInt = 15 * 1024 * 1024       // Max 15 MB RAM
    static let maxImageCacheSize: UInt = 30 * 1024 * 1024             // Max 30 MB disk cache
    static let imageCacheKey = "PosterImageCache"
  }

  private let imageCache: PINCache = {
    let cache = PINCache(name: Constants.imageCacheKey)
    cache.diskCache.byteLimit = Constants.maxImageCacheSize
    cache.diskCache.ageLimit = Constants.imageCacheAgeLimit
    cache.memoryCache.costLimit = Constants.maxImageMemoryCostLimit
    return cache
  }()

  func moviePoster(forPath path: String, callback: @escaping (String, UIImage?) -> Void) {
    imageCache.object(forKey: path) { (_, key, poster) in
      callback(key, poster as? UIImage)
    }
  }

  func add(moviePoster poster: UIImage?, with path: String) {
    guard let image = poster else {
      return
    }

    imageCache.setObject(image, forKey: path)
  }
}

extension Sequence where Iterator.Element: Equatable {
  func unique() -> [Iterator.Element] {
    return reduce([], { collection, element in collection.contains(element) ? collection : collection + [element] })
  }
}
