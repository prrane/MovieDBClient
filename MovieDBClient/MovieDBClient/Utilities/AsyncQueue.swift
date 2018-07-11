//
//  SearchQueue.swift
//  FlickrWall
//
//  Created by Prashant Rane.
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
