//
//  ListItem.swift
//  RandomListAssessment
//
//  Created by Haley Jones on 6/14/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CoreData
//Models you want to save to core data are defined in the .xcdatamodel, so if you wanna add to them you ned to do so through extensions.
//gotta extend a core data model to give it a proper initializer.
extension ListItem{
    @discardableResult
    convenience init(name: String, context: NSManagedObjectContext = CoreDataStack.context){
            self.init(context: context)
            self.name = name
            self.uuid = UUID().uuidString
    }
    
}
