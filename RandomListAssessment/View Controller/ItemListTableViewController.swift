//
//  ItemListTableViewController.swift
//  RandomListAssessment
//
//  Created by Haley Jones on 6/14/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import CoreData

class ItemListTableViewController: UITableViewController {
    
    //MARK: Properties
    //tells us if they're in a shuffled view or the base list's view.
    var groupMode = false
    
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //pull all the list items from the persistent store.
        let request: NSFetchRequest<ListItem> = ListItem.fetchRequest()
        ListItemController.shared.listItems = try! CoreDataStack.context.fetch(request)
    }
    
    //MARK: IBActions
    
    @IBAction func shuffleButtonPressed(_ sender: UIBarButtonItem) {
        //change action based on current mode.
        if (groupMode){
            ListItemController.shared.clearGroups()
        } else {
            ListItemController.shared.splitIntoPairs()
        }
        //flip the bool
        groupMode = !groupMode
        //update text
        shuffleButton.title = groupMode ? "Ungroup" : "Shuffle"
        //reload
        self.tableView.reloadData()
    }
    @IBAction func addButtonPressed(_ sender: Any) {
        //present the alert controller to make a new item. Gotta make it first.
        let newItemAlert = UIAlertController(title: "New Item", message: nil, preferredStyle: .alert)
        //add a text field so they can type a thing in
        newItemAlert.addTextField { (textField) in
            textField.placeholder = "Enter item name"
        }
        let addItemAction = UIAlertAction(title: "Add", style: .default) { (action) in
            //grab the name from the text field
            guard let itemName = newItemAlert.textFields?[0].text, itemName != "" else {
                 //the alert controller for if they dont enter an item name
                let noNameController = UIAlertController(title: "Wait...", message: "A new item must have a name.", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Got it.", style: .destructive) { (action) in
                    self.present(newItemAlert, animated: true)
                }
                noNameController.addAction(closeAction)
                self.present(noNameController, animated: true)
                return
            }
            //create the new item, add it to the source of truth
            ListItemController.shared.createItem(withName: itemName)
            //and reload to show their new thing.
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (alert) in
            //
        }
        newItemAlert.addAction(addItemAction)
        newItemAlert.addAction(cancelAction)
        //actually present the controller
        self.present(newItemAlert, animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupMode ? ListItemController.shared.groups.count : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMode ? ListItemController.shared.groups[section].count : ListItemController.shared.listItems.count
    }

    //Configure the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        //we want to access different arrays from the shared instance depending on what mode the app is in.
        //Wanted to maybe do a computed property but this seemed safer with the delete functions and all.
        if !groupMode{
            let cellItem = ListItemController.shared.listItems[indexPath.row]
            cell.textLabel?.text = cellItem.name
        } else {
            print("in the tableview configure cell else")
            let cellItem = ListItemController.shared.groups[indexPath.section][indexPath.row]
            cell.textLabel?.text = cellItem.name
        }
        return cell
    }
    
    //A new delegate function that lets me set the title for a section.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if groupMode{
            return "Group \(section + 1)"
        } else {
            return "All Items"
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //find the item to delete in different arrays based on whether or not the table is currently using the Groups or AllItems array.
            if !groupMode{
                //the usual
                let targetItem = ListItemController.shared.listItems[indexPath.row]
                ListItemController.shared.deleteItem(item: targetItem, fromGroup: 0)
            } else {
                //use the index's section member to subscript the matrix & get the right group, then subscript that array with .row
                let targetItem = ListItemController.shared.groups[indexPath.section][indexPath.row]
                ListItemController.shared.deleteItem(item: targetItem, fromGroup: indexPath.section)
            }
            //then u delete stuff.
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
