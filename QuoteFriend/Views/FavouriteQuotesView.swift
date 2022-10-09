//
//  FavouriteQuotesView.swift
//  QuoteFriend
//
//  Created by Liam Jones on 30/11/2021.
//

import SwiftUI
import CoreData

struct FavouriteQuotesView: View {
  @Environment(\.managedObjectContext) var context
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \QuoteManagedObject.q, ascending: true)],
    predicate: NSPredicate(format: "approved == true"),
    animation: .default
  ) private var likedQuotes: FetchedResults<QuoteManagedObject>

  var body: some View {
    List {
      ForEach(likedQuotes, id: \.q) { quote in
        VStack {
          Text(quote.q ?? "X")
            .bold()
            .font(.system(.body, design: .serif))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .padding([.top, .bottom], 5)
            .padding([.leading, .trailing])
          Text(" - " + (quote.a ?? "X"))
            .bold()
            .font(.system(Font.TextStyle.caption, design: .serif))
        }
        .frame(maxWidth: .infinity)
      }
      .onDelete(perform: delete)
    }
  }
  
  func delete(at offsets: IndexSet) {
    likedQuotes.delete(at: offsets, in: context)
  }
}

struct FavouriteQuotesView_Previews: PreviewProvider {
  static var previews: some View {
    return FavouriteQuotesView()
      .environmentObject(QuoteCollection())
  }
}


