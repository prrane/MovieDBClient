//
//  SearchKeywordCell.swift
//  MovieDBClient
//
//  Created by Prashant Rane.
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
