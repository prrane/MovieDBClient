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
    static let defaultPadding: CGFloat = 8.0
    static let leftLayoutMargins: CGFloat = 14.0

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

//    layer.borderWidth = 1
//    layer.borderColor = UIColor.green.cgColor
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

  public func setup(with viewModel: Movie) {
    self.viewModel = viewModel

    titleLabel.text = viewModel.title
    releaseDateLabel.text = viewModel.releaseDate
    overviewLabel.text = viewModel.overview

    setNeedsLayout()
    layoutIfNeeded()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let availableFrame = frame.insetBy(dx: layoutMargins.left, dy: layoutMargins.top).integral

    var currentTop: CGFloat = 0
    let titleSize = titleLabel.sizeThatFits(availableFrame.size)
    titleLabel.size = titleSize
    titleLabel.top = currentTop
    titleLabel.left = 0

    currentTop = titleLabel.bottom + Constants.defaultPadding
    releaseDateLabel.sizeToFit()
    releaseDateLabel.top = currentTop
    releaseDateLabel.left = 0

    currentTop = releaseDateLabel.bottom + Constants.defaultPadding
    let availableHeight = availableFrame.height - currentTop
    let overviewSize = overviewLabel.sizeThatFits(CGSize(width: availableFrame.width, height: availableHeight))
    overviewLabel.size = overviewSize
    overviewLabel.top = currentTop
    overviewLabel.left = 0
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    guard let viewModel = viewModel else {
      return .zero
    }

    let boundingRectForTitle = viewModel.title.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.titleFont], context: nil).integral

    let boundingRectForReleaseDate = viewModel.releaseDate.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.releaseDateFont], context: nil).integral

    let boundingRectForOverview = viewModel.overview.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.overviewFont], context: nil).integral

    let maxHeight = boundingRectForTitle.height + boundingRectForReleaseDate.height + boundingRectForOverview.height + 2 * Constants.defaultPadding

    return CGSize(width: size.width, height: maxHeight)
  }

  class func size(for viewModel: Movie, width: CGFloat) -> CGSize {

    let availableSize = CGSize(width: width - 2 * Constants.leftLayoutMargins, height: .greatestFiniteMagnitude)

    let boundingRectForTitle = viewModel.title.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.titleFont], context: nil).integral

    let boundingRectForReleaseDate = viewModel.releaseDate.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.releaseDateFont], context: nil).integral

    let boundingRectForOverview = viewModel.overview.boundingRect(with: availableSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: Constants.overviewFont], context: nil).integral

    let maxHeight = boundingRectForTitle.height + boundingRectForReleaseDate.height + boundingRectForOverview.height + 2 * Constants.defaultPadding

    return CGSize(width: width, height: maxHeight)
  }
}
