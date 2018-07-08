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
    tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.reuseIdentifier)
    return tableView
  }()

  init(with tableViewDelegate: UITableViewDelegate, tableViewDatasource: UITableViewDataSource) {
    super.init(frame: .zero)

    tableView.delegate = tableViewDelegate
    tableView.dataSource = tableViewDatasource
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

}
