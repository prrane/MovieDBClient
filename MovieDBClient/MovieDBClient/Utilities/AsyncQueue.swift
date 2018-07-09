//
//  SearchQueue.swift
//  FlickrWall
//
//  Created by Prashant Rane on 01/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import Foundation

public class AsyncQueue {
  private let operationQueue = OperationQueue()

  init(named name: String, maxConcurrentOperationCount: Int = 1) {
    operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
    operationQueue.qualityOfService = .userInteractive
    operationQueue.name = name
  }

  func cancelAllOperations() {
    operationQueue.cancelAllOperations()
  }

  func addOperation(_ operation: Operation) {
    operationQueue.addOperation(operation)
  }

}
