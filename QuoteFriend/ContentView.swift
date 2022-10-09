//
//  ContentView.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import SwiftUI

struct ContentView: View {
  
  @Environment(\.managedObjectContext) var context
  @StateObject var quoteCollection = QuoteCollection()
  
  var body: some View {
    TabView {
      QuoteListView(quoteCollection: quoteCollection)
        .tabItem {
          Label("Find New", systemImage: "quote.bubble")
        }
      FavouriteQuotesView()
        .tabItem {
          Label("Faves", systemImage: "checkmark.circle")
        }
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.fill")
        }
    }
    .onAppear { quoteCollection.loadQuotes(context: context) }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(QuoteCollection())
  }
}
