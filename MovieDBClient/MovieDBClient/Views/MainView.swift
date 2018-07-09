//
//  MainView.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MainView: UIView {

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
    searchBar.searchBarStyle = .prominent

    return searchController
  }()

  init(with tableViewDelegate: UITableViewDelegate, tableViewDatasource: UITableViewDataSource, searchResultsController: UISearchBarDelegate) {

    super.init(frame: .zero)

    tableView.delegate = tableViewDelegate
    tableView.dataSource = tableViewDatasource
    tableView.tableHeaderView = searchController.searchBar

//    searchController.searchResultsUpdater = searchResultsController
    searchController.searchBar.delegate = searchResultsController

    addSubview(tableView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  public func setup() {
    self.backgroundColor = .lightGray
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    tableView.frame = frame
  }

  func reload() {
    tableView.reloadData()
  }

  func dismissSearch() {
    searchController.isActive = false
  }
  
}
