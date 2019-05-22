//
//  MasterController.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit
import CoreData

class MasterController: UITableViewController {
    
    let managedObjectContext = CoreDataStack().managedObjectContext
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var quickNote: UITextField!
    @IBOutlet weak var dateOfTheDay: UILabel!
    
    lazy var dataSource: DataSource = {
        return DataSource(tableView: self.tableView, context: self.managedObjectContext)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let newButton = UIBarButtonItem(image: UIImage(named: "Icn_write"), style: .done, target: self, action: #selector(MasterController.launchDetailController))
        navigationItem.rightBarButtonItem = newButton
        dateOfTheDay.text = Date().dateOfTheDay()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        // Add a fake note
//        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
//        note.text = "Hello note"
//        note.modificationDate = NSDate()
//        note.longitude = 0.0
//        note.latitude = 0.0
        
      //  managedObjectContext.saveChanges()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func launchDetailController() {
        performSegue(withIdentifier: "NewNoteSegue", sender: self)
    
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewNoteSegue" {
            
            let navigatioController = segue.destination as! UINavigationController
            let addNoteController = navigatioController.topViewController as! DetailController
            
            addNoteController.managedObjectContext = self.managedObjectContext
            addNoteController.update = false
        } else if segue.identifier == "showDetail" {
            let navigatioController = segue.destination as! UINavigationController
            let updateNoteController = navigatioController.topViewController as! DetailController
            updateNoteController.update = true
            if let indexPath = tableView.indexPathForSelectedRow {
                let note = dataSource.object(at: indexPath)
                updateNoteController.note = note
                updateNoteController.managedObjectContext = self.managedObjectContext
            }
        }
            
    }
    
    @IBAction func returnTapped(_ sender: UITextField) {
        guard let text = quickNote.text, !text.isEmpty else {
            return
        }
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
        
        if let text = quickNote.text {
            note.text = text
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            note.text = text
           // note.modificationDate = dateFormatter.string(from: Date())
            note.modificationDate = "Thursday, May 23, 2019"
            note.longitude = 0.0
            note.latitude = 0.0
            note.locationDescription = "📍 No location"
            note.smiley = "none"
            note.photos = nil
            managedObjectContext.saveChanges() // save the context on disk
         //   tableView.reloadData()
            
            quickNote.text = nil
            quickNote.placeholder = "Quick note"
            sender.resignFirstResponder()
          //  dismiss(animated: true, completion: nil)
        }
    }
    

}
