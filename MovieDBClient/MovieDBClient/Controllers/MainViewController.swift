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

    self.view = MainView(with: self, tableViewDatasource: datasource)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Search Movies", comment: "Navigation bar title for Main Screen")

    // Setup main view
    mainView.setup()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

extension MainViewController: UITableViewDelegate {
  
}
