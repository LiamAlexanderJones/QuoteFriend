//
//  TestQuoteData.swift
//  QuoteFriendTests
//
//  Created by Liam Jones on 20/12/2021.
//

import Foundation

enum TestQuoteData {
  
  static let goodJson = """

[
    {"q":"Life would be tragic if it weren't funny.","a":"Stephen Hawking","c":"41","h":"<blockquote>&ldquo;Life would be tragic if it weren't funny.&rdquo; &mdash; <footer>Stephen Hawking</footer></blockquote>"},
    {"q":"Nothing is easier than fault finding.","a":"Og Mandino","c":"37","h":"<blockquote>&ldquo;Nothing is easier than fault finding.&rdquo; &mdash; <footer>Og Mandino</footer></blockquote>"},
    {"q":"The pen is the tongue of the mind. ","a":"Miguel de Cervantes","c":"35","h":"<blockquote>&ldquo;The pen is the tongue of the mind. &rdquo; &mdash; <footer>Miguel de Cervantes</footer></blockquote>"},
    {"q":"You have the ability, now apply yourself.","a":"Benjamin Mays","c":"41","h":"<blockquote>&ldquo;You have the ability, now apply yourself.&rdquo; &mdash; <footer>Benjamin Mays</footer></blockquote>"},
    {"q":"Don't be afraid of enemies who attack you. Be afraid of the friends who flatter you.","a":"Dale Carnegie","c":"84","h":"<blockquote>&ldquo;Don't be afraid of enemies who attack you. Be afraid of the friends who flatter you.&rdquo; &mdash; <footer>Dale Carnegie</footer></blockquote>"}
]

"""
  
  static let badJson = """
[bad data]

"""
  
}
