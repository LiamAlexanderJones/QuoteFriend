//
//  QuoteCollection.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class QuoteCollection: ObservableObject {
  @Published var downloadedQuotes: [Quote] = []
  @Published var loadError: Error? = nil
  var subscriptions: Set<AnyCancellable> = []
  let client: APIClientProtocol
  
  init(client: APIClientProtocol = APIClient()) {
    self.client = client
  }
  
  func loadQuotes(context: NSManagedObjectContext) {
    client.publisher()
      .map { quotes -> [Quote] in
        //We filter out quotes the user has already saved. If we can't get the saved quotes, we just present the quotes as they are (rather than thorwing an error)
        let fetchRequest: NSFetchRequest<QuoteManagedObject>
        fetchRequest = QuoteManagedObject.fetchRequest()
        let savedQuotes = try? context.fetch(fetchRequest).compactMap {
          if let q = $0.q, let a = $0.h, let h = $0.h {
            return Quote(q: q, a: a, h: h)
          } else {
            return nil
          }
        }
        if let savedQuotes = savedQuotes {
          return Array(Set(quotes).subtracting(Set(savedQuotes)))
        } else {
          return quotes
        }
      }
      .sink(receiveCompletion: { result in
        if case .failure(let error) = result {
          self.loadError = error
        }
      }, receiveValue: { quotes in
        self.downloadedQuotes = quotes
      })
      .store(in: &subscriptions)
  }
}




