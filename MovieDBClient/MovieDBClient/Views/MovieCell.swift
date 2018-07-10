//
//  MovieCell.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

  struct Constants {
    static let verticalPadding: CGFloat = 8.0
    static let horizontalPadding: CGFloat = 20.0
    static let labelHorizontalPadding: CGFloat = 10.0

    static let titleFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let releaseDateFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .light)
    static let overviewFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
  }

  static var reuseIdentifier: String {
    return String(describing: type(of: self))
  }

  let posterView = PosterView()
  let movieDetailsView = MovieDetailsView()

  let hairlineBottom: UIView = {
    let hairline = UIView(frame: .zero)
    hairline.height = 1.0 / UIScreen.main.scale
    hairline.backgroundColor = .lightGray
    return hairline
  }()

  var viewModel: Movie? = nil

  override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(posterView)
    contentView.addSubview(movieDetailsView)
    contentView.addSubview(hairlineBottom)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func setup(with viewModel: Movie, poster: UIImage?) {
    self.viewModel = viewModel

    movieDetailsView.setup(with: viewModel)
    posterView.setup(with: poster)

    layoutSubviews()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    posterView.prepareForReuse()
    movieDetailsView.prepareForReuse()
  }

  class func size(for viewModel: Movie, width: CGFloat) -> CGSize {
    let posterSize = PosterView.defaultSize
    let availableWidth = width - posterSize.width - 2 * Constants.horizontalPadding
    let detailsViewSize = MovieDetailsView.size(for: viewModel, width: availableWidth)
    let height = max(posterSize.height, detailsViewSize.height) + 2 * Constants.verticalPadding + 1.0 / UIScreen.main.scale
    return CGSize(width: width, height: height)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard viewModel != nil else {
      return
    }

    let avilableFrame = contentView.frame.insetBy(dx: contentView.layoutMargins.left, dy: contentView.layoutMargins.top).integral
    
    posterView.left = avilableFrame.minX
    posterView.size = PosterView.defaultSize
    posterView.top = avilableFrame.minY

    let availableWidth = avilableFrame.width - posterView.width -  Constants.labelHorizontalPadding
    movieDetailsView.left = posterView.right + Constants.labelHorizontalPadding
    movieDetailsView.top = posterView.top

    let detailsViewSize = movieDetailsView.sizeThatFits(CGSize(width: availableWidth, height: avilableFrame.height))
    movieDetailsView.size = detailsViewSize

    hairlineBottom.frame = CGRect(x: 0, y: contentView.bottom - hairlineBottom.height, width: contentView.width, height: hairlineBottom.height)
  }

}
