//
//  SettingsVIew.swift
//  QuoteFriend
//
//  Created by Liam Jones on 05/12/2021.
//

import SwiftUI
import CoreData

struct SettingsView: View {
  @Environment(\.managedObjectContext) var context
  @State var showDeleteRejectedQuotesAlert = false
  @State var showDeleteSavedQuotesAlert = false
  @State var showRejectedQuotes = false
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \QuoteManagedObject.q, ascending: true)],
    predicate: NSPredicate(format: "approved == true"),
    animation: .default
  ) private var likedQuotes: FetchedResults<QuoteManagedObject>
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \QuoteManagedObject.q, ascending: true)],
    predicate: NSPredicate(format: "approved == false"),
    animation: .default
  ) private var rejectedQuotes: FetchedResults<QuoteManagedObject>
  
  var body: some View {
    VStack {
      Button(action: {
        showDeleteRejectedQuotesAlert = true
      }, label: {
        Text("Clear Rejected Quotes")
          .bold()
          .font(.system(.body))
          .padding()
          .foregroundColor(.white)
          .background(Color.black)
          .clipShape(Capsule())
      })
      .alert(isPresented: $showDeleteRejectedQuotesAlert) {
        Alert(
          title: Text("Are you sure you want to clear rejected quotes?"),
          message: Text("If you clear rejected quotes, they will be able to appear in the new quotes list again."),
          primaryButton: .destructive(Text("Delete"), action: {
            rejectedQuotes.deleteAll(in: context)
          }),
          secondaryButton: .cancel())
      }
      .padding()
      Button(action: {
        showDeleteSavedQuotesAlert = true
      }, label: {
        Text("Delete Saved Quotes")
          .bold()
          .font(.system(.body))
          .padding()
          .foregroundColor(.white)
          .background(Color.black)
          .clipShape(Capsule())
      })
      .alert(isPresented: $showDeleteSavedQuotesAlert) {
        Alert(
          title: Text("Are you sure you want to delete your quotes?"),
          message: Text("If you delete your saved quotes, you won't be able to access them until they appear in the New Quotes section."),
          primaryButton: .destructive(Text("Delete"), action: {
            likedQuotes.deleteAll(in: context)
          }),
          secondaryButton: .cancel())
      }
      .padding()
      Button(action: {
        showRejectedQuotes = true
      }, label: {
        Text("View Rejected Quotes")
          .bold()
          .font(.system(.body))
          .padding()
          .foregroundColor(.white)
          .background(Color.black)
          .clipShape(Capsule())
      })
      .sheet(isPresented: $showRejectedQuotes) {
        RejectedQuotesView()
      }
      .padding()
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
      .environmentObject(QuoteCollection())
  }
}
