//
//  UIView+Framing.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 10/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import UIKit

struct CenteringAxis: OptionSet {
  public let rawValue: Int8

  static let horizontal = CenteringAxis(rawValue: 1 << 0)
  static let vertical = CenteringAxis(rawValue: 1 << 1)
}

extension UIView {

  var size: CGSize {
    get {
      return frame.size
    }
    set {
      let origin = frame.origin
      self.frame = CGRect(origin: origin, size: newValue).integral
    }
  }


  var width: CGFloat {
    get {
      return frame.size.width
    }
    set {
      self.frame.size.width = newValue
    }
  }

  var height: CGFloat {
    get {
      return frame.size.height
    }
    set {
      self.frame.size.height = newValue
    }
  }

  var left: CGFloat {
    get {
      return frame.origin.x
    }
    set {
      frame.origin.x = newValue
    }
  }

  var right: CGFloat {
    get {
      return frame.origin.x + width
    }
    set {
      left = newValue - width
    }
  }

  var top: CGFloat {
    get {
      return frame.origin.y
    }
    set {
      frame.origin.y = newValue
    }
  }

  var bottom: CGFloat {
    get {
      return frame.origin.y + height
    }
    set {
      frame.origin.y = newValue - height
    }
  }

  func centerInSuperview(axis: CenteringAxis) {
    guard let superViewRef = superview else {
      return
    }

    if axis.contains(.horizontal) {
      left = floor((superViewRef.width - width) * 0.5)
    }
    
    if axis.contains(.vertical) {
      top = floor((superViewRef.height - height) * 0.5)
    }
  }
}
