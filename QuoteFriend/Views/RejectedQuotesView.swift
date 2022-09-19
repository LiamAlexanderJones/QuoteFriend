//
//  RejectedQuotesView.swift
//  QuoteFriend
//
//  Created by Liam Jones on 08/12/2021.
//

import SwiftUI

struct RejectedQuotesView: View {
    
    @EnvironmentObject var quoteCollection: QuoteCollection
    @Environment(\.managedObjectContext) var context
 
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \QuoteManagedObject.q, ascending: true)],
        predicate: NSPredicate(format: "approved == false"),
        animation: .default
    ) private var rejectedQuotes: FetchedResults<QuoteManagedObject>
    
    
    var body: some View {
        List {
            ForEach(rejectedQuotes, id: \.q) {
                Text(($0.q ?? "X") + " - " + ($0.a ?? "X"))
            }
        }
    }
}

struct RejectedQuotesView_Previews: PreviewProvider {
    static var previews: some View {
        RejectedQuotesView()
    }
}
