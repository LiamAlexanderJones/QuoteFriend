//
//  QuoteFriendApp.swift
//  QuoteFriend
//
//  Created by Liam Jones on 25/11/2021.
//

import SwiftUI
import CoreData


@main
struct QuoteFriendApp: App {
    
    //@StateObject var quoteCollection = QuoteCollection()
    @Environment(\.scenePhase) var phase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.environmentObject(quoteCollection)
                .environment(\.managedObjectContext, CoreDataStack.viewContext)
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .background {
                CoreDataStack.save()
            }
        }
    }
}

private enum CoreDataStack {
    
    static var viewContext: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("\(#file), \(#function), \(error.localizedDescription)")
            }
        }
        return container.viewContext
    }()
    
    static func save() {
        do {
            try viewContext.save()
        } catch {
            fatalError("\(#file), \(#function), \(error.localizedDescription)")
        }
    }
    
}

