//
//  MovieDBClientTests.swift
//  MovieDBClientTests
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import XCTest
@testable import MovieDBClient

private enum TestDataType {
  case success, successWithNoPoster, successWithNoResults, failure, error

  var fileName: String {
    switch self {
    case .success:                return "valid_response"
    case .successWithNoPoster:    return "valid_response_no_poster"
    case .successWithNoResults:   return "valid_response_no_results"
    case .failure:                return "failure_response"
    case .error:                  return "error_response"
    }
  }
}

class MovieDBClientTests: XCTestCase {

  private func jsonData(for type: TestDataType) -> Data {
    guard let path = Bundle(for: MovieDBClientTests.self).path(forResource: type.fileName, ofType: "json") else {
      XCTFail("\nCould not get path for file : \(type.fileName).json \n")
      return Data(bytes: [])
    }

    guard let data = FileManager.default.contents(atPath: path) else {
      XCTFail("\nCould not get data from file path: \(path)\n")
      return Data(bytes: [])
    }

    return data
  }

  private func valiateForSuccess(response: APIResponse) {
    if let success = response.success, !success {
      XCTFail("\nFound failure in valid response: => \(String(describing: response.statusMessage))\n")
      return
    }

    guard response.errors == nil else {
      XCTFail("\nFound error in valid response: => \(String(describing: response.errors))\n")
      return
    }
  }

  func testMovieSearchSuccess() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let response = try decoder.decode(APIResponse.self, from: jsonData(for: .success))
      valiateForSuccess(response: response)

      XCTAssert(response.currentPage == 1, "Current page index decoded is wrong")

      guard !response.movies.isEmpty else {
        XCTFail("No Movies found in valid response\n")
        return
      }

      let movie = response.movies.first!

      XCTAssert(movie.title == "Batman", "Movie title does not matches with test data")
      XCTAssert(movie.releaseDate == "1989-06-23", "Movie release date does not matches with test data")
      XCTAssert(movie.posterPath == "/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg", "Movie poster path is decoded incorrectly")
    }
    catch let error {
      XCTFail("\n==>\n\(error)\n")
    }
  }

  func testMovieSearchSuccessWithNoPoster() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let response = try decoder.decode(APIResponse.self, from: jsonData(for: .successWithNoPoster))
      valiateForSuccess(response: response)

      guard !response.movies.isEmpty else {
        XCTFail("No Movies found in valid response\n")
        return
      }

      let movie = response.movies.first!

      XCTAssert(movie.title == "Batman", "Movie title does not matches with test data")
      XCTAssert(movie.releaseDate == "1989-06-23", "Movie release date does not matches with test data")
      XCTAssert(movie.posterPath == nil, "Movie poster path is decoded incorrectly")
    }
    catch let error {
      XCTFail("\n==>\n\(error)\n")
    }
  }

  func testMovieSearchSuccessWithNoResult() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let response = try decoder.decode(APIResponse.self, from: jsonData(for: .successWithNoResults))
      valiateForSuccess(response: response)
      XCTAssert(response.movies.isEmpty, "No Movies should be available in empty response\n")
    }
    catch let error {
      XCTFail("\n==>\n\(error)\n")
    }
  }

  func testMovieSearchFailure() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let response = try decoder.decode(APIResponse.self, from: jsonData(for: .failure))

      XCTAssert(response.currentPage == 0, "Current page index decoded is wrong")
      XCTAssert(response.totalPages == 0, "Total pages decoded is wrong")
      XCTAssert(response.totalResults == 0, "Total results decoded is wrong")
      XCTAssert(!(response.success ?? true), "failure response should have success == false \n")

      XCTAssert(response.movies.isEmpty, "No Movies should be available in case of failure response\n")
    }
    catch let error {
      XCTFail("\n==>\n\(error)\n")
    }
  }

  func testMovieSearchError() {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let response = try decoder.decode(APIResponse.self, from: jsonData(for: .error))

      XCTAssert(!(response.errors?.isEmpty ?? true), "No Movies should be available in case of failure response\n")

      XCTAssert(response.currentPage == 0, "Current page index decoded is wrong")
      XCTAssert(response.totalPages == 0, "Total pages decoded is wrong")
      XCTAssert(response.totalResults == 0, "Total results decoded is wrong")

      XCTAssert(response.movies.isEmpty, "No Movies should be available in case of failure response\n")
    }
    catch let error {
      XCTFail("\n==>\n\(error)\n")
    }
  }

}
