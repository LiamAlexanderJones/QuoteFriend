//
//  QuoteFriendTests.swift
//  QuoteFriendTests
//
//  Created by Liam Jones on 25/11/2021.
//

import CoreData
import XCTest
import Combine
@testable import QuoteFriend


class QuoteFriendTests: XCTestCase {
  var dummyContext: NSManagedObjectContext!
  
  override func setUp() {
    super.setUp()
    dummyContext = TestCoreDataStack.makeViewContext()
  }
  
  override func tearDown() {
    super.tearDown()
    dummyContext = nil
  }
  
  func test_likeQuote() {
    //Given
    let quote = Quote(q: "A quote", a: "An attribution", h: "HTML field")
    //When
    QuoteManagedObject.save(quote: quote, approved: true, context: dummyContext)
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    let results = try? dummyContext.fetch(fetchRequest)
    let savedQuote = results?.first
    //Then
    XCTAssert(results?.count == 1)
    XCTAssertEqual(savedQuote?.q, quote.q)
    XCTAssertEqual(savedQuote?.a, quote.a)
    XCTAssertEqual(savedQuote?.approved, true)
  }
  
  func test_dislikeQuote() {
    //Given
    let quote = Quote(q: "A quote", a: "An attribution", h: "HTML field")
    //When
    QuoteManagedObject.save(quote: quote, approved: false, context: dummyContext)
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    let results = try? dummyContext.fetch(fetchRequest)
    let savedQuote = results?.first
    //Then
    XCTAssert(results?.count == 1)
    XCTAssertEqual(savedQuote?.q, quote.q)
    XCTAssertEqual(savedQuote?.a, quote.a)
    XCTAssertEqual(savedQuote?.approved, false)
  }
  
  func test_filterLikedQuotes() {
    //Given
    let qmos: [QuoteManagedObject] = [true, false, true].map {
      let qmo = QuoteManagedObject(context: dummyContext)
      qmo.q = $0 ? "Liked Quote" : "Disliked Quote"
      qmo.a = "Attribution"
      qmo.h = "HTML field"
      qmo.approved = $0
      return qmo
    }
    qmos.forEach { dummyContext.insert($0) }
    XCTAssertNoThrow(try dummyContext.save())
    //When
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    fetchRequest.predicate = NSPredicate(format: "approved == true")
    let results = try? dummyContext.fetch(fetchRequest)
    //Then
    XCTAssertEqual(results?.count, 2)
    XCTAssertEqual(results?[0].q, qmos[0].q)
    XCTAssertEqual(results?[1].q, qmos[2].q)
  }
  
  func test_filterDislikedQuotes() {
    //Given
    let qmos: [QuoteManagedObject] = [true, false, true].map {
      let qmo = QuoteManagedObject(context: dummyContext)
      qmo.q = $0 ? "Liked Quote" : "Disliked Quote"
      qmo.a = "Attribution"
      qmo.h = "HTML field"
      qmo.approved = $0
      return qmo
    }
    qmos.forEach { dummyContext.insert($0) }
    XCTAssertNoThrow(try dummyContext.save())
    //When
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    fetchRequest.predicate = NSPredicate(format: "approved == false")
    let results = try? dummyContext.fetch(fetchRequest)
    //Then
    XCTAssertEqual(results?.count, 1)
    XCTAssertEqual(results?[0].q, qmos[1].q)
  }
  
  func test_deleteQuote() throws {
    //Given
    let qmos: [QuoteManagedObject] = (1...5).map {
      let qmo = QuoteManagedObject(context: dummyContext)
      qmo.q = "Quote \($0)"
      qmo.a = "Attribution \($0)"
      qmo.h = "HTML field"
      qmo.approved = true
      return qmo
    }
    qmos.forEach { dummyContext.insert($0) }
    XCTAssertNoThrow(try dummyContext.save())
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    //When
    qmos.delete(at: IndexSet(integer: 0), in: dummyContext)
    //Then
    let results = try dummyContext.fetch(fetchRequest)
    XCTAssertEqual(qmos.count - 1, results.count)
    XCTAssertTrue(results.contains(qmos[1]))
    XCTAssertTrue(results.contains(qmos[2]))
    XCTAssertTrue(results.contains(qmos[3]))
    XCTAssertTrue(results.contains(qmos[4]))
    XCTAssertFalse(results.contains(qmos[0]))
  }
  
  func test_deleteAllQuotes() throws {
    //Given
    let qmos: [QuoteManagedObject] = (1...5).map {
      let qmo = QuoteManagedObject(context: dummyContext)
      qmo.q = "Quote \($0)"
      qmo.a = "Attribution \($0)"
      qmo.h = "HTML field"
      qmo.approved = true
      return qmo
    }
    qmos.forEach { dummyContext.insert($0) }
    XCTAssertNoThrow(try dummyContext.save())
    let fetchRequest = NSFetchRequest<QuoteManagedObject>()
    fetchRequest.entity = QuoteManagedObject.entity()
    //When
    qmos.deleteAll(in: dummyContext)
    //Then
    let results = try dummyContext.fetch(fetchRequest)
    XCTAssertTrue(results.isEmpty)
  }
  
  func test_loadQuotes() {
    //Given
    struct FakeAPIClient: APIClientProtocol {
      static let quotes: [Quote] = (1...5).map {
        Quote(q: "Quote \($0)", a: "Attribution \($0)", h: "HTML field")
      }
      func publisher() -> AnyPublisher<[Quote], Error> {
        let publisher = CurrentValueSubject<[Quote], Error>(FakeAPIClient.quotes)
          .eraseToAnyPublisher()
        return publisher
      }
    }
    //When
    let quoteCollection = QuoteCollection(client: FakeAPIClient())
    //Then
    XCTAssertEqual(quoteCollection.downloadedQuotes, FakeAPIClient.quotes)
  }
  
  func test_loadQuotesWithFilter() {
    //TODO: Add filter test
  }
  
  func test_loadQuotesWithError() {
    //Given
    struct FakeAPIClient: APIClientProtocol {
      static let quotes: [Quote] = (1...5).map {
        Quote(q: "Quote \($0)", a: "Attribution \($0)", h: "HTML field")
      }
      func publisher() -> AnyPublisher<[Quote], Error> {
        let publisher = Fail<[Quote], Error>(error: APIError.requestFailed(0))
          .eraseToAnyPublisher()
        return publisher
      }
    }
    //When
    let quoteCollection = QuoteCollection(client: FakeAPIClient())
    //Then
    if let error = quoteCollection.loadError {
      switch error {
      case APIError.requestFailed(let status):
        XCTAssertEqual(status, 0)
      default:
        XCTFail("Wrong error type: \(error)")
      }
    } else {
      XCTFail("QuoteCollection.loadError is nil")
    }
    XCTAssertNotNil(quoteCollection.loadError)
    XCTAssert(quoteCollection.loadError is APIError)
  }
  
  func test_APIClientPublisherWithGoodData() {
    //Given
    struct MockSession: QuotePublisherMaker {
      func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError> {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let data = TestQuoteData.goodJson.data(using: .utf8)!
        return Result.Publisher((data: data, response: response))
          .eraseToAnyPublisher()
      }
    }
    var subscriptions: Set<AnyCancellable> = []
    let client = APIClient(session: MockSession())
    var resultQuotes: [Quote] = []
    let expectation = self.expectation(description: "Client handles good data")
    //When
    client.publisher()
      .sink(receiveCompletion: { completion in
        if case .failure(let error) = completion {
          XCTFail("Completion failed with error: \(error)")
        }
      }, receiveValue: { quotes in
        resultQuotes = quotes
        expectation.fulfill()
      })
      .store(in: &subscriptions)
    //Then
    waitForExpectations(timeout: 1)
    XCTAssertEqual(resultQuotes.count, 5)
    XCTAssertEqual(resultQuotes.first?.q, "Life would be tragic if it weren't funny.")
  }
  
  func test_APIClientPublisherWithBadData() {
    //Given
    struct MockSession: QuotePublisherMaker {
      func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError> {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let data = TestQuoteData.badJson.data(using: .utf8)!
        return Result.Publisher((data: data, response: response))
          .eraseToAnyPublisher()
      }
    }
    var subscriptions: Set<AnyCancellable> = []
    let client = APIClient(session: MockSession())
    let expectation = self.expectation(description: "Client handles bad data")
    //When
    client.publisher()
      .sink(receiveCompletion: { completion in
        //Then
        if case .finished = completion {
          XCTFail("Call succeded")
        }
        if case .failure(let error) = completion {
          switch error {
          case APIError.requestFailed(let status):
            XCTFail("Call produced failed request error type, with status code \(status)")
          case APIError.processingFailed(_):
            break
          default:
            XCTFail("Call didn't produce API Error")
          }
        }
        expectation.fulfill()
      }, receiveValue: { quotes in
        XCTFail("Quotes produced: \(quotes)")
      })
      .store(in: &subscriptions)
    waitForExpectations(timeout: 1)
  }
  
  func test_APIClientPublisherWith404Error() {
    //Given
    struct MockSession: QuotePublisherMaker {
      func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError> {
        let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!
        let data = TestQuoteData.goodJson.data(using: .utf8)!
        return Result.Publisher((data: data, response: response))
          .eraseToAnyPublisher()
      }
    }
    var subscriptions: Set<AnyCancellable> = []
    let client = APIClient(session: MockSession())
    let expectation = self.expectation(description: "Client handles 404")
    //When
    client.publisher()
      .sink(receiveCompletion: { completion in
        //Then
        if case .finished = completion {
          XCTFail("Call succeded")
        }
        if case .failure(let error) = completion {
          switch error {
          case APIError.requestFailed(let status):
            XCTAssertEqual(status, 404)
          case APIError.processingFailed(let err):
            XCTFail("Call produced processingFailed error with error type \(String(describing: err))")
          default:
            XCTFail("Call didn't produce API Error")
          }
        }
        expectation.fulfill()
      }, receiveValue: { quotes in
        XCTFail("Quotes produced: \(quotes)")
      })
      .store(in: &subscriptions)
    waitForExpectations(timeout: 1)
  }
  
  func test_APIClientPublisherWithNetworkError() {
    //Given
    struct MockSession: QuotePublisherMaker {
      func quotePublisher(for request: URLRequest) -> AnyPublisher<QuoteResponse, URLError> {
        return Result.Publisher(URLError(.timedOut))
          .eraseToAnyPublisher()
      }
    }
    var subscriptions: Set<AnyCancellable> = []
    let client = APIClient(session: MockSession())
    let expectation = self.expectation(description: "Client handles network error")
    //When
    client.publisher()
      .sink(receiveCompletion: { completion in
        //Then
        if case .finished = completion {
          XCTFail("Call succeded")
        }
        if case .failure(let error) = completion {
          switch error {
          case APIError.requestFailed(let status):
            XCTFail("Call produced failed request error type, with status code \(status)")
          case APIError.processingFailed(_):
            break
          default:
            XCTFail("Call didn't produce API Error")
          }
        }
        expectation.fulfill()
      }, receiveValue: { quotes in
        XCTFail("Quotes produced: \(quotes)")
      })
      .store(in: &subscriptions)
    waitForExpectations(timeout: 1)
  }

}
