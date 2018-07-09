//
//  ViewController.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  private var mainView: MainView {
    return view as! MainView
  }

  private var datasource = MovieResultsDataSource()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()

    self.view = MainView(with: self, tableViewDatasource: datasource, searchResultsController: datasource)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Search Movies", comment: "Navigation bar title for Main Screen")

    // Setup main view
    mainView.setup()

    datasource.datasourceUpdatedCallback = mainView.reload
    datasource.searchDismissCallback = mainView.dismissSearch
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

extension MainViewController: UITableViewDelegate {
  
}
//
//extension MainViewController: UISearchResultsUpdating {
//
//  func updateSearchResults(for searchController: UISearchController) {
//    datasource.searchKeyword = searchController.searchBar.text
//  }
//
//}
//
//extension MainViewController: UISearchBarDelegate {
//
//  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//    datasource.isSearching = true
//    mainView.reload()
//  }
//
//  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//    datasource.isSearching = false
//    mainView.reload()
//  }
//
//  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//    searchBar.resignFirstResponder()
//    datasource.searchKeyword = searchBar.text
//    datasource.isSearching = false
//  }
//
//}
//
