//
//  PosterView.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 10/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

class PosterView: UIView {

  // Aspect ratio for poster is 1:1.5
  struct Constants {
    static let width: CGFloat = 100
    static let height: CGFloat = width * 1.5

    static let defaultPadding: CGFloat = 10.0
  }

  let imageView: UIImageView = {
    let imageView: UIImageView = UIImageView(image: nil)
    imageView.contentMode = .scaleAspectFill
    imageView.isHidden = false
    return imageView
  }()

  let loadingLabel: UILabel = {
    let loadingLabel = UILabel(frame: .zero)
    loadingLabel.textColor = .lightGray
    loadingLabel.font = .systemFont(ofSize: 14)
    loadingLabel.contentMode = .center
    loadingLabel.textAlignment = .center

    loadingLabel.text = NSLocalizedString("loading...", comment: "Placeholder string for till image is loaded")
    return loadingLabel
  }()

  private var image: UIImage? = nil {
    didSet {
      guard let image = image else {
        imageView.image = nil
        imageView.isHidden = true
        loadingLabel.isHidden = false
        return
      }

      imageView.image = image
      imageView.isHidden = false
      loadingLabel.isHidden = true
    }
  }

  init() {
    super.init(frame: .zero)

    addSubview(loadingLabel)
    addSubview(imageView)
    
    decorateViewsWithBorder()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func prepareForReuse() {
    self.imageView.image = nil
  }

  func setup(with image: UIImage?, movie: Movie?) {
    self.image = image

    setNeedsLayout()
    layoutIfNeeded()
  }

  class var defaultSize: CGSize {
    return CGSize(width: Constants.width + Constants.defaultPadding, height: Constants.height + Constants.defaultPadding)
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return PosterView.defaultSize
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if image != nil {
      imageView.frame = bounds.insetBy(dx: Constants.defaultPadding, dy: Constants.defaultPadding).integral
      loadingLabel.frame = .zero
    }
    else {
      imageView.frame = .zero
      loadingLabel.frame = bounds.insetBy(dx: Constants.defaultPadding, dy: Constants.defaultPadding).integral
    }
  }

  // A debug helper method
  private func decorateViewsWithBorder() {
    guard ProcessInfo().environment["DEBUG_BORDER"] != nil else {
      return
    }

    layer.borderWidth = 1.0 / UIScreen.main.scale
    layer.borderColor = UIColor.black.cgColor

    imageView.layer.borderWidth = 1.0 / UIScreen.main.scale
    imageView.layer.borderColor = UIColor.yellow.cgColor

    loadingLabel.layer.borderWidth = 1.0 / UIScreen.main.scale
    loadingLabel.layer.borderColor = UIColor.red.cgColor
  }
}
