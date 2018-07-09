//
//  Models.swift
//  MovieDBClient
//
//  Created by Prashant Rane on 08/07/18.
//  Copyright © 2018 Prashant Rane. All rights reserved.
//

import Foundation

/**
 `APIResponse->response` Sample data
  "title": "Batman",
  "release_date": "1989-06-23",
  "overview": "The Dark Knight of Gotham City begins his war on crime with his first major enemy being the clownishly homicidal Joker",
  "poster_path": "\/kBf3g9crrADGMc2AMAMlLBgSm2h.jpg"
  */
struct Movie: Codable {
  let title: String
  let releaseDate: String
  let overview: String
  let posterPath: String? // this is optional as per API Docs
}

/**
 `APIResponse` Sample Data
   "page": 1000,
   "total_results": 106,
   "total_pages": 6,
   "results": []

      OR

   "status_code": 7,
   "status_message": "Invalid API key: You must be granted a valid key.",
   "success": false

    OR

  "errors": ["query must be provided"]
 */

enum APIError {
  case success
  case error(message: String)
}

struct APIResponse: Codable {
  // Success
  let currentPage: Int  // Starts from `1`
  let totalResults: Int
  let totalPages: Int
  let movies: [Movie]

  // Error
  let statusMessage: String?
  let success: Bool?
  let errors: [String]?

  var apiError: APIError {
    let hasError = !(success ?? true) && !((errors ?? []).isEmpty)
    let errorMessage = statusMessage ?? errors?.joined(separator: "\n") ?? NSLocalizedString("Something went wrong, please try later", comment: "Generic error message")

    return hasError ? .error(message: errorMessage) : .success
  }

  private enum CodingKeys: String, CodingKey {
    // Success
    case currentPage = "page"
    case totalResults
    case totalPages
    case movies = "results"

    // Error
    case statusMessage
    case success
    case errors
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let currentPage = try? container.decode(Int.self, forKey: .currentPage)
    self.currentPage = currentPage ?? 0
    let totalResults = try? container.decode(Int.self, forKey: .totalResults)
    self.totalResults = totalResults ?? 0
    let totalPages = try? container.decode(Int.self, forKey: .totalPages)
    self.totalPages = totalPages ?? 0
    let movies = try? container.decode([Movie].self, forKey: .movies)
    self.movies = movies ?? []

    statusMessage = try? container.decode(String.self, forKey: .statusMessage)
    success = try? container.decode(Bool.self, forKey: .success)
    errors = try? container.decode([String].self, forKey: .errors)
  }

}
