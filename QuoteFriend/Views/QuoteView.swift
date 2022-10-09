//
//  QuoteView.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import SwiftUI

struct QuoteView: View {
  var quote: Quote
  var quoteCollection: QuoteCollection
  let screenSize = UIScreen.main.bounds.size
  @State var offset: CGSize = .zero
  @Environment(\.managedObjectContext) var context
  
  var body: some View {
    VStack {
      Spacer()
      Text(quote.q)
        .foregroundColor(.white)
        .bold()
        .font(.system(.largeTitle, design: .serif))
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.1)
      Text(" ~ \(quote.a) ~ ")
        .foregroundColor(.white)
        .bold()
        .textCase(.uppercase)
        .font(.system(Font.TextStyle.body, design: .serif))
        .padding()
      Spacer()
      HStack {
        Button(action: {
          judgeQuote(approve: true)
        }, label: {
          Image(systemName: "checkmark.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.green)
            .background(.white)
            .clipShape(Circle())
            .frame(width: screenSize.width / 5.0)
        })
        Spacer()
        Button(action: {
          judgeQuote(approve: false)
        }, label: {
          Image(systemName: "xmark.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.red)
            .background(.white)
            .clipShape(Circle())
            .frame(width: screenSize.width / 5.0)
        })
      }
      .padding()
    }
    .background(Color.black)
    .cornerRadius(25)
    .padding(10)
    .overlay(content: {
      Image(systemName: offset.width > 0 ? "checkmark.circle" : "xmark.circle")
        .resizable()
        .scaledToFit()
        .foregroundColor(offset.width > 0 ? .green : .red)
        .opacity(abs(offset.width) / 150.0)
        .frame(width: abs(offset.width) + 40)
    })
    .offset(offset)
    .animation(.easeIn, value: offset)
    .gesture(
      DragGesture()
        .onChanged {
          self.offset = $0.translation
        }
        .onEnded {
          switch $0.translation.width {
          case let width where width > 150:
            judgeQuote(approve: true)
          case let width where width < -150:
            judgeQuote(approve: false)
          default:
            self.offset = .zero
          }
        }
    )
  }
  
  func judgeQuote(approve: Bool) {
    self.offset.width += approve ? 1000 : -1000
    QuoteManagedObject.save(quote: quote, approved: approve, context: context)
    if quote == quoteCollection.downloadedQuotes.first {
      quoteCollection.downloadedQuotes = []
      quoteCollection.loadQuotes(context: context)
    }
  }
}

struct QuoteView_Previews: PreviewProvider {
  static var previews: some View {
    QuoteView(quote: Quote(q: "No doubt a terribly deep thing said once in the past, and indeed it is an extemely long quote that might perhaps struggle to fit in the quote view at its current size, perhaps it could be resized to some degree.", a: "Someone Famous", h: "AAA"), quoteCollection: QuoteCollection())
  }
}
