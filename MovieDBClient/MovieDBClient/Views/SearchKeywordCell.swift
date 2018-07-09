//
//  SearchKeywordCell.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 09/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class SearchKeywordCell: UITableViewCell {

  static var reuseIdentifier: String {
    return String(describing: type(of: self))
  }

  public func setup(with keword: String) {
    textLabel?.text = keword
  }

}
