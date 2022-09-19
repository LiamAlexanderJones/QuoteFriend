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
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuoteManagedObject.q, ascending: true)],
        predicate: nil,
        animation: .default
    ) private var savedQuotes: FetchedResults<QuoteManagedObject>
    
    @Published var downloadedQuotes: [Quote] = []
    @Published var loadError: Error? = nil
    var subscriptions: Set<AnyCancellable> = []
    let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient()) {
        self.client = client
        loadQuotes()
    }
    
    func loadQuotes() {
        client.publisher()
            .sink(receiveCompletion: { result in
                if case .failure(let error) = result {
                    self.loadError = error
                }
            }, receiveValue: { quotes in
                let filteredQuotes =  quotes.filter { quote in
                    !self.savedQuotes.map { $0.q }.contains(quote.q)
                }
                //We need to filter out quotes the user has already saved from the results. It seems cleaner to do it here than in the view. Unfortunately, this makes it hard to test. (I can't get a simple fetch request to work).
                self.downloadedQuotes = filteredQuotes
            })
            .store(in: &subscriptions)
    }

    
    
}



