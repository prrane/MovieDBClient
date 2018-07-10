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
    static let width: CGFloat = 80
    static let height: CGFloat = 80 * 1.5

    static let defaultPadding: CGFloat = 8.0
  }

  let imageView: UIImageView = {
    let imageView: UIImageView = UIImageView(image: nil)
    imageView.contentMode = .scaleAspectFit
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
    
//    layer.borderWidth = 1
//    layer.borderColor = UIColor.red.cgColor
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func prepareForReuse() {
    imageView.image = nil
    image = nil
  }

  func setup(with image: UIImage?) {
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
      imageView.frame = frame.insetBy(dx: layoutMargins.left, dy: layoutMargins.top).integral
      loadingLabel.frame = .zero
    }
    else {
      imageView.frame = .zero
      loadingLabel.frame = frame.insetBy(dx: layoutMargins.left, dy: layoutMargins.top).integral
      loadingLabel.centerInSuperview(axis: [.vertical, .horizontal])
    }
  }

}
