//
//  APIClientProtocol.swift
//  QuoteFriend
//
//  Created by Liam Jones on 13/12/2021.
//

import Foundation
import Combine

protocol APIClientProtocol {
  func publisher() -> AnyPublisher<[Quote], Error>
}

