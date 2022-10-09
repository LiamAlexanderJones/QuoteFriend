//
//  TestCoreDataStack.swift
//  QuoteFriendTests
//
//  Created by Liam Jones on 09/12/2021.
//

import CoreData
@testable import QuoteFriend

enum TestCoreDataStack {
  static var makeViewContext: () -> NSManagedObjectContext = {
    let description = NSPersistentStoreDescription()
    description.url = URL(fileURLWithPath: "/dev/null")
    let container = NSPersistentContainer(name: "DataModel")
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { _, error in
      if let error = error {
        fatalError("Test Store Error: \(#file), \(#function), \(error.localizedDescription)")
      }
    }
    return container.newBackgroundContext()
  }
}


