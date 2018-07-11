//
//  MovieDetailsView.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 10/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MovieDetailsView: UIView {

  struct Constants {
    static let defaultPadding: CGFloat = 10.0
    static let verticalPaddingBetweenTitleAndDate: CGFloat = 3.0
    static let verticalPaddingBetweenDateAndOverview: CGFloat = 8.0

    static let titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let releaseDateFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .light)
    static let overviewFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
  }

  let titleLabel: UILabel = {
    let titleLabel = UILabel(frame: .zero)
    titleLabel.font = Constants.titleFont
    titleLabel.numberOfLines = 0
    titleLabel.lineBreakMode = .byWordWrapping
    return titleLabel
  }()

  let releaseDateLabel: UILabel = {
    let releaseDateLabel = UILabel(frame: .zero)
    releaseDateLabel.font = Constants.releaseDateFont
    return releaseDateLabel
  }()

  let overviewLabel: UILabel = {
    let overviewLabel = UILabel(frame: .zero)
    overviewLabel.font = Constants.overviewFont
    overviewLabel.numberOfLines = 0
    overviewLabel.lineBreakMode = .byWordWrapping
    return overviewLabel
  }()

  private var viewModel: Movie? = nil

  init() {
    super.init(frame: .zero)

    addSubview(titleLabel)
    addSubview(releaseDateLabel)
    addSubview(overviewLabel)

    decorateViewsWithBorder()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func prepareForReuse() {
    viewModel = nil
    titleLabel.text = ""
    releaseDateLabel.text = ""
    overviewLabel.text = ""
  }

  public func setup(with viewModel: Movie?) {
    guard self.viewModel != viewModel else {
      return
    }
    
    self.viewModel = viewModel

    titleLabel.text = viewModel?.title
    releaseDateLabel.text = viewModel?.releaseDate
    overviewLabel.text = viewModel?.overview

    setNeedsLayout()
    layoutIfNeeded()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let availableFrame = bounds.insetBy(dx: Constants.defaultPadding, dy: Constants.defaultPadding).integral

    var currentTop: CGFloat = availableFrame.origin.y
    let left = availableFrame.origin.x
    let titleSize = titleLabel.sizeThatFits(availableFrame.size)
    titleLabel.size = titleSize
    titleLabel.top = currentTop
    titleLabel.left = left
    currentTop = titleLabel.bottom + Constants.verticalPaddingBetweenTitleAndDate

    releaseDateLabel.sizeToFit()
    releaseDateLabel.top = currentTop
    releaseDateLabel.left = left
    currentTop = releaseDateLabel.bottom + Constants.verticalPaddingBetweenDateAndOverview

    let availableHeight = availableFrame.height - currentTop - Constants.defaultPadding
    let overviewSize = overviewLabel.sizeThatFits(CGSize(width: availableFrame.width, height: availableHeight))
    overviewLabel.size = overviewSize
    overviewLabel.top = currentTop
    overviewLabel.left = left
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    guard let viewModel = viewModel else {
      return .zero
    }

    // Adjust available width for insets
    let availableSize = CGSize(width: size.width - 2 * Constants.defaultPadding, height: size.height)
    let height = MovieDetailsView.height(for: viewModel, availableSize: availableSize) + 2 * Constants.defaultPadding
    return CGSize(width: size.width, height: height)
  }

  class func size(for viewModel: Movie, width: CGFloat) -> CGSize {
    // Adjust available width for insets
    let availableSize = CGSize(width: width - 2 * Constants.defaultPadding, height: .greatestFiniteMagnitude)
    let height = MovieDetailsView.height(for: viewModel, availableSize: availableSize) + 2 * Constants.defaultPadding
    return CGSize(width: width, height: height)
  }

  private class func height(for viewModel: Movie, availableSize: CGSize) -> CGFloat {
    let boundingRectForTitle = viewModel.title.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.titleFont], context: nil).integral

    let boundingRectForReleaseDate = viewModel.releaseDate.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.releaseDateFont], context: nil).integral

    let boundingRectForOverview = viewModel.overview.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.overviewFont], context: nil).integral

    // Add the padding between labels
    let maxHeight = boundingRectForTitle.height + boundingRectForReleaseDate.height + boundingRectForOverview.height + Constants.verticalPaddingBetweenTitleAndDate + Constants.verticalPaddingBetweenDateAndOverview

    return maxHeight
  }

  // A debug helper method
  private func decorateViewsWithBorder() {
    guard ProcessInfo().environment["DEBUG_BORDER"] != nil else {
      return
    }

    layer.borderWidth = 1.0 / UIScreen.main.scale
    layer.borderColor = UIColor.black.cgColor

    titleLabel.layer.borderWidth = 1.0 / UIScreen.main.scale
    titleLabel.layer.borderColor = UIColor.blue.cgColor

    releaseDateLabel.layer.borderWidth = 1.0 / UIScreen.main.scale
    releaseDateLabel.layer.borderColor = UIColor.green.cgColor

    overviewLabel.layer.borderWidth = 1.0 / UIScreen.main.scale
    overviewLabel.layer.borderColor = UIColor.red.cgColor
  }

}
