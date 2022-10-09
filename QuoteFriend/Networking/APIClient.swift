//
//  APIClient.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import Foundation
import Combine

enum APIError: Error {
  case requestFailed(Int)
  case processingFailed(Error?)
}

protocol QuotePublisherMaker {
  typealias QuoteResponse = URLSession.DataTaskPublisher.Output
  func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError>
}

extension URLSession: QuotePublisherMaker {
  func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError> {
    return dataTaskPublisher(for: request).eraseToAnyPublisher()
  }
}

struct APIClient: APIClientProtocol {
  
  let session: QuotePublisherMaker
  let decoder = JSONDecoder()
  
  init(session: QuotePublisherMaker = URLSession.shared) {
    self.session = session
  }
  
  func publisher() -> AnyPublisher<[Quote], Error> {
    
    guard let url = URL(string: "https://zenquotes.io/api/quotes")
    else { fatalError("Couldn't get zenquotes URL") }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    
    let publisher = session.quotePublisher(for: urlRequest)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
          let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
          throw APIError.requestFailed(statusCode)
        }
        return data
      }
      .decode(type: [Quote].self, decoder: decoder)
      .tryCatch { error -> AnyPublisher<[Quote], Error> in
        switch error {
        case APIError.requestFailed(_):
          throw error
        default:
          throw APIError.processingFailed(error)
        }
      }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
    return publisher
  }
}
