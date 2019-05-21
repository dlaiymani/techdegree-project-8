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
        return fetchResultsController.sections?.count ?? 0
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
        context.delete(note)
        context.saveChanges()
        
    }
    
    private func configureCell(_ cell: NoteCell, at indexPath: IndexPath) -> NoteCell {
        let note = fetchResultsController.object(at: indexPath)
        
        let noteDate = note.modificationDate as Date
        
        cell.noteDate.text = "\(noteDate.dateOfTheDay())"
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
        case "non":
            cell.smileyImageView.image = nil

        default:
            break
            
        }
        
        return cell
    }
    
}
