//
//  QuoteManagedObject+.swift
//  QuoteFriend
//
//  Created by Liam Jones on 07/12/2021.
//

import Foundation
import CoreData


extension QuoteManagedObject {
    
    static func save(quote: Quote, approved: Bool, context: NSManagedObjectContext) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: String(describing: QuoteManagedObject.self)
        )
        fetchRequest.predicate = NSPredicate(format: "q == %@", quote.q)
        
        if let results = try? context.fetch(fetchRequest),
           let existing =  results.first as? QuoteManagedObject {
            existing.q = quote.q
            existing.a = quote.a
            existing.h = quote.h
            existing.approved = approved
        } else {
            let new = self.init(context: context)
            new.q = quote.q
            new.a = quote.a
            new.h = quote.h
            new.approved = approved
        }
        do {
            try context.save()
        } catch {
            fatalError("\(#file) \(#function) \(error.localizedDescription)")
        }
    }
    
}

extension Collection where Element == QuoteManagedObject, Index == Int {
    
    func delete(at indices: IndexSet, in context: NSManagedObjectContext) {
        indices.forEach { index in
            context.delete(self[index])
        }
        do {
            try context.save()
        } catch {
            fatalError("\(#file) \(#function) \(error.localizedDescription)")
        }
    }
    
    func deleteAll(in context: NSManagedObjectContext) {
        self.indices.forEach { index in
            context.delete(self[index])
        }
        do {
            try context.save()
        } catch {
            fatalError("\(#file) \(#function) \(error.localizedDescription)")
        }
    }
    
}


