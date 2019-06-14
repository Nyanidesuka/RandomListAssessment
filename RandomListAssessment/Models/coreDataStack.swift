//
//  coreDataStack.swift
//  RandomListAssessment
//
//  Created by Haley Jones on 6/14/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CoreData
//why not review core data, it is a friend
class CoreDataStack{
    static let container: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "RandomListAssessment")
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let anError = error {
                fatalError("There was in error in \(#function). \(anError.localizedDescription)")
            }
        })
        return persistentContainer
    }()
    
    static var context: NSManagedObjectContext {
        return container.viewContext
    }
}
