//  MainView.swift
//
//  Created by Prashant Rane.
//

import UIKit

class MainView: UIView {

  let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero)
    tableView.tableFooterView = UIView(frame: .zero)
    
    tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseIdentifier)
    tableView.register(SearchKeywordCell.self, forCellReuseIdentifier: SearchKeywordCell.reuseIdentifier)

    return tableView
  }()

  let searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    searchController.definesPresentationContext = true

    let searchBar = searchController.searchBar
    searchBar.autocapitalizationType = .none
    searchBar.autocorrectionType = .no
    searchBar.spellCheckingType = .no
    searchBar.searchBarStyle = .minimal
    searchBar.placeholder = NSLocalizedString("Enter keywords", comment: "Placeholder text for movie search bar")

    return searchController
  }()

  init(with tableViewDelegate: UITableViewDelegate, tableViewDatasource: UITableViewDataSource, searchBarDelegate: UISearchBarDelegate) {

    super.init(frame: .zero)

    tableView.delegate = tableViewDelegate
    tableView.dataSource = tableViewDatasource
    tableView.tableHeaderView = searchController.searchBar

    searchController.searchBar.delegate = searchBarDelegate

    addSubview(tableView)
    addSubview(activityIndicator)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setup() {
    self.backgroundColor = .white

    refresh()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if #available(iOS 11.0, *) {
      let left = safeAreaInsets.left
      let top = safeAreaInsets.top
      let width = bounds.width - safeAreaInsets.left - safeAreaInsets.right
      let height = bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
      tableView.frame = CGRect(x: left, y: top, width: width, height: height)
    }
    else {
      tableView.frame = frame
    }

    activityIndicator.center = center
  }

  func displayActivityIndicator(_ shouldDisplayActivityIndicator: Bool) -> Void {
      if shouldDisplayActivityIndicator {
        activityIndicator.startAnimating()
      }
      else {
        activityIndicator.stopAnimating()
      }
  }

  func refresh() {
    tableView.reloadData()
  }

  func dismissSearch() {
    searchController.isActive = false    
  }
  
}
