//
//  ListItemController.swift
//  RandomListAssessment
//
//  Created by Haley Jones on 6/14/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CoreData

class ListItemController{
    
    //Shared instance, private initializer so nothing else can make one.
    static let shared = ListItemController()
    private init(){}
    
    //⚔️source of truth ⚔️
    //an array to store every item the user has entered
    var listItems: [ListItem] = []
    //an array to store the groups of items they split that list into.
    var groups: [[ListItem]] = []
    
    //CRUD Functions
    
    func createItem(withName name: String){
        let newItem = ListItem(name: name)
        //core data!
        saveToPersistentStore()
        //and add it to the source of truth.
        ListItemController.shared.listItems.append(newItem)
    }
    //delete from both the arrays, and also the persistent store. Taking in a section to make things a little easier.
    func deleteItem(item: ListItem, fromGroup group: Int){
        //grab the UUID so we dont have to mess with equatable 🧠
        let uuid = item.uuid
        //delete it from the master list of items
        guard let index = ListItemController.shared.listItems.firstIndex(where: {$0.uuid == uuid}) else {return}
        ListItemController.shared.listItems.remove(at: index)
        //also delete it from the groups if there's groups.
        if !ListItemController.shared.groups.isEmpty{
            guard let indexInGroup = ListItemController.shared.groups[group].firstIndex(where: {$0.uuid == uuid}) else {return}
            ListItemController.shared.groups[group].remove(at: indexInGroup)
        }
        //and now delete from the persistent store.
        if let moc = item.managedObjectContext{
            moc.delete(item)
        }
        //after all that, save to the persistent store.
        saveToPersistentStore()
    }
    
    func shuffleFullList(){
        //using .shuffle we can do some basic randomizing on the array. We don't save it because i feel like we wanna preserve original order.
        ListItemController.shared.listItems.shuffle()
    }
    
    func splitIntoPairs(){
        shuffleFullList()
        //disposable copy of SoT, i wanna try to preserve the original list.
        var listItemsCopy = ListItemController.shared.listItems
        //an array to return
        var returnArray: [[ListItem]] = []
        //making this an int should chop the remainder off.
        let numberOfPairs: Int = listItemsCopy.count / 2
        for _ in 1...numberOfPairs{
            //stick the first two elements of the copy in a group
            var newGroup = [listItemsCopy[0], listItemsCopy[1]]
            //then chop them off the list copy so the next pass gets new items.
            listItemsCopy.removeFirst()
            listItemsCopy.removeFirst()
            //then add the new group to the retur array
            returnArray.append(newGroup)
        }
        //if there's any stragglers, make a group of one.
        if listItemsCopy.count != 0{
            returnArray.append(listItemsCopy)
        }
        //After all that's done, set the shared instance's group array to  equal what we just made
        ListItemController.shared.groups = returnArray
        print("groups: \(ListItemController.shared.groups.count)")
    }
    
    func clearGroups(){
        //empty the groups array
        ListItemController.shared.groups = []
        //pull from the persistent store which should restore the original order of the list.
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        ListItemController.shared.listItems = try! CoreDataStack.context.fetch(request)
    }
    //gotta be able to save
    func saveToPersistentStore(){
        //grab the context
        let moc = CoreDataStack.context
        do{
            //and then core data makes it REAL easy for us.
            try moc.save()
        } catch {
            //descriptive errors+++
            print("There was an error saving to the persistent store. \(error.localizedDescription)")
        }
    }
}
