//
//  QuoteListView.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import SwiftUI

struct QuoteListView: View {
    
    @StateObject var quoteCollection = QuoteCollection()

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(quoteCollection.downloadedQuotes, id: \.q) {
                QuoteView(quote: $0, quoteCollection: quoteCollection)
            }
            if let error = quoteCollection.loadError {
                VStack {
                    Text("Unfortunately QuoteFriend failed to load quotes. Click the button below to try loeading the quotes. The nature error message is: \(error.localizedDescription)")
                        .bold()
                        .font(.system(.body))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Rectangle())
                    Button(action: {
                        quoteCollection.loadQuotes()
                    }, label: {
                        Text("Reload")
                            .bold()
                            .font(.system(.body))
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black)
                            .clipShape(Capsule())
                    })
                }
            }
        }
    }
}

struct QuoteListView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteListView()
            .environmentObject(QuoteCollection())
    }
}
