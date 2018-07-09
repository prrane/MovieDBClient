//
//  AsyncOperation.swift
//  FlickrWall
//
//  Created by Prashant Rane on 01/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import Foundation

open class AsyncOperation: Operation {

  @objc public enum State: Int {
    case ready, executing, finished, error

    var keyPath: String {
      switch self {
      case .ready:
        return "isReady"
      case .executing:
        return "isExecuting"
      case .finished:
        return "isFinished"
      case .error:
        return "isError"
      }
    }
  }

  @objc open dynamic var state: State = .ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }

  override public init() {
    state = .ready
    super.init()
  }

  override open var isReady: Bool {
    return super.isReady && state == .ready
  }

  override open var isExecuting: Bool {
    return state == .executing
  }

  override open var isFinished: Bool {
    return state == .finished
  }

  override open var isAsynchronous: Bool {
    return true
  }
}
