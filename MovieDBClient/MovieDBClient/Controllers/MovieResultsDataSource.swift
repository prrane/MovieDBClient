//
//  MovieResultsDataSource.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MovieResultsDataSource: NSObject, UITableViewDataSource {

  // ivars to be set during initialization
  var datasourceUpdatedCallback: (() -> Void)?
  var searchDismissCallback: (() -> Void)?

  private var keywordsDatasource: [String] {
    guard let keyword = searchKeyword, !keyword.isEmpty else {
      return CacheManager.keywordCache.keywords
    }

    let predicate = NSPredicate(format: "SELF CONTAINS[c] %@", keyword)
    return CacheManager.keywordCache.keywords.filter { predicate.evaluate(with: $0) }
  }

  private var searchKeyword: String? = nil {
    didSet {
      datasourceUpdatedCallback?()
    }
  }

  private var isSearching: Bool = false

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isSearching ? keywordsDatasource.count : 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard !isSearching else {
      let cell = tableView.dequeueReusableCell(withIdentifier: SearchKeywordCell.reuseIdentifier, for: indexPath) as! SearchKeywordCell
      cell.setup(with: keywordsDatasource[indexPath.row])
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.reuseIdentifier, for: indexPath) as! MovieCell
    cell.setup()

    return cell
  }

}

extension MovieResultsDataSource: UISearchBarDelegate {

  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    isSearching = true
    searchKeyword = nil
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    isSearching = false
    searchKeyword = nil
    searchDismissCallback?()
  }

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {    
    searchKeyword = searchBar.text
    isSearching = false

    guard let keyword = searchKeyword, !keyword.isEmpty else {
      searchDismissCallback?()
      return
    }

    guard keyword.count > 2 else {
      // show alert
      print("you should enter a minimum 3 words for search")
      return
    }

    searchDismissCallback?()
    // Search keyword
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchKeyword = searchText
  }

}
