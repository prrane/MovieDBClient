//
//  MovieResultsDataSource.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

typealias Callback = (() -> Void)?

class MovieResultsController: NSObject {

  // ivars to be set during initialization
  private var refreshCallback: (() -> Void)?
  private var dismissSearchCallback: (() -> Void)?

  let searchController = SearchController()

  private var movieDatasource: SearchResultsCache {
    return CacheManager.searchResultsCache
  }

  private var keywordsDatasource: [String] {
    guard let keyword = searchKeyword, !keyword.isEmpty else {
      return CacheManager.keywordCache.keywords
    }

    let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", keyword)
    return CacheManager.keywordCache.keywords.filter { predicate.evaluate(with: $0) }
  }

  private var searchKeyword: String? = nil {
    didSet {
      refreshCallback?()
    }
  }

  private var isSearching: Bool = false

  func setup(with refreshCallback: Callback, dismissSearchCallback: Callback) {
    self.refreshCallback = refreshCallback
    self.dismissSearchCallback = dismissSearchCallback

    searchController.setup(with: refreshCallback)
  }
}

// MARK: - UITableViewDataSource

extension MovieResultsController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return isSearching ? 1 : movieDatasource.numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows(inSection: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard !isSearching else {
      return searchKeywordCell(for: indexPath, in: tableView)
    }

    return movieCell(for: indexPath, in: tableView)
  }

  // MARK: Helpers

  private func numberOfRows(inSection: Int) -> Int {
    return isSearching ? keywordsDatasource.count : movieDatasource.movies(forSection: inSection).count
  }

  private func movieCell(for indexPath: IndexPath, in tableView: UITableView) -> MovieCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
    cell.setup(with: movieDatasource.item(forIndexPath: indexPath), poster: nil)

    if indexPath.row == movieDatasource.movies(forSection: indexPath.section).count - 1 {
      if movieDatasource.shouldPrefetch(forSection: indexPath.section + 1) {
        searchController.getNextPage()
      }
    }

    return cell
  }

  private func searchKeywordCell(for indexPath: IndexPath, in tableView: UITableView) -> SearchKeywordCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SearchKeywordCell.reuseIdentifier, for: indexPath) as! SearchKeywordCell
    cell.setup(with: keywordsDatasource[indexPath.row])

    return cell
  }

}

// MARK: - UITableViewDelegate

extension MovieResultsController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if isSearching {
      return 40
    }
    else {
      return movieCellHeight(for: indexPath, in: tableView)
    }
  }

  private func movieCellHeight(for indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
    guard let viewModel = movieDatasource.item(forIndexPath: indexPath) else {
      return 0
    }
    return MovieCell.size(for: viewModel, width: tableView.width).height
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if isSearching {
      let cell = searchKeywordCell(for: indexPath, in: tableView)
      let keyword = cell.textLabel?.text

      guard let searchKeyword = keyword else {
        isSearching = false
        dismissSearchCallback?()
        refreshCallback?()
        return
      }

      searchController.search(keyword: searchKeyword)
      isSearching = false
      dismissSearchCallback?()
      refreshCallback?()
    }
  }

}

// MARK: - UISearchBarDelegate

extension MovieResultsController: UISearchBarDelegate {

  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    isSearching = true
    searchKeyword = nil
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    isSearching = false
    searchKeyword = nil
    dismissSearchCallback?()
  }

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchKeyword = searchBar.text
    isSearching = false

    guard let keyword = searchKeyword, !keyword.isEmpty else {
      dismissSearchCallback?()
      return
    }

    guard keyword.count > 2 else {
      // show alert
      print("you should enter a minimum 3 words for search")
      return
    }

    dismissSearchCallback?()
    // Search keyword

    searchController.search(keyword: keyword)
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchKeyword = searchText
  }

}