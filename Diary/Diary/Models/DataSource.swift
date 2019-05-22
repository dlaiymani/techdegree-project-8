//
//  DataSource.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataSource: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    private let context: NSManagedObjectContext
    
    lazy var fetchResultsController: NoteFetchResultsController = {
        
        return NoteFetchResultsController(managedObjectContext: self.context, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        self.tableView = tableView
        self.context = context
    }
    
    
    func object(at indexPath: IndexPath) -> Note {
        return fetchResultsController.object(at: indexPath)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let section = fetchResultsController.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        
        return configureCell(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let note = fetchResultsController.object(at: indexPath)
        
//        if self.fetchResultsController.sections?[indexPath.section].numberOfObjects == 1 {
//            let indexSet = IndexSet(integer: indexPath.section)
//            print(indexSet)
//            self.tableView.deleteSections(indexSet, with: .fade)
//        }
//        print(self.fetchResultsController.sections?[indexPath.section].numberOfObjects)
//
//        print(indexPath.section)
//        self.tableView.beginUpdates()
//        if self.fetchResultsController.sections?[indexPath.section].numberOfObjects == 1 {
//            let indexSet = IndexSet(integer: indexPath.section)
//            print(indexSet)
//            self.tableView.deleteSections(indexSet, with: .fade)
//        } else {
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//        self.tableView.endUpdates()

        context.delete(note)
        context.saveChanges()
       // self.tableView.deleteRows(at: [indexPath], with: .automatic)

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = fetchResultsController.sections?[section] else {
            return nil
        }
        
        return section.name
        
    }
    
    
    
    
    private func configureCell(_ cell: NoteCell, at indexPath: IndexPath) -> NoteCell {
        let note = fetchResultsController.object(at: indexPath)
        
        
        cell.noteDate.text = "\(note.modificationDate)"
        cell.noteText.text = note.text
        if let locationDescription = note.locationDescription {
            cell.localisationNote.text = "\(locationDescription)"
        } else {
            cell.localisationNote.text = "No location"
        }
        
        switch note.smiley {
        case "bad":
            cell.smileyImageView.image = UIImage(named: "icn_bad")
        case "average":
            cell.smileyImageView.image = UIImage(named: "icn_average")
        case "happy":
            cell.smileyImageView.image = UIImage(named: "icn_happy")
        case "none":
            cell.smileyImageView.image = nil

        default:
            break
            
        }
        
        return cell
    }
    
}
