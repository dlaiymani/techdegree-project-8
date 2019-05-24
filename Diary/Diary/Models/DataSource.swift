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

// Data source for the Master TableView i.e. list of Notes
class DataSource: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    private let context: NSManagedObjectContext // CoreData context
    
    // CoreData fetch controller
    lazy var fetchResultsController: NoteFetchResultsController = {
        return NoteFetchResultsController(fetchRequest: Note.fetchRequest(), managedObjectContext: self.context, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        self.tableView = tableView
        self.context = context
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchResultsController.sections?[section] else {
            return 0
        }
        
        return section.numberOfObjects
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        
        return configureCell(cell, at: indexPath)
    }
    
    // Deleting a row i.e. a Note
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let note = fetchResultsController.object(at: indexPath)
        context.delete(note)
        context.saveChanges()
        tableView.reloadData()
    }
    
    // Display a note in a cell
    private func configureCell(_ cell: NoteCell, at indexPath: IndexPath) -> NoteCell {
        let note = fetchResultsController.object(at: indexPath)
        
        cell.noteDate.text = "\(note.modificationDate)"
        cell.noteText.text = note.text
        cell.localisationNote.text = "\(note.locationDescription)"
        
        // For the rounded "vignette"
        cell.noteImageView.layer.cornerRadius = cell.noteImageView.frame.height/2
        cell.noteImageView.clipsToBounds = true
        cell.noteImageView.image = UIImage(named: "icn_noimage")
        if let photos = note.photos {
            for photo in photos {
                if photo.isMainPhoto {
                    cell.noteImageView.image = photo.image
                }
            }
        }
        cell.smileyImageView.image = smileyImage(forNote: note)

        return cell
    }
    
    // MARK: - Helpers
    
    // Returns the Note at a given IndexPath
    func object(at indexPath: IndexPath) -> Note {
        return fetchResultsController.object(at: indexPath)
    }
    
    // Return the smiley image corresponding to a smiley. Would be better to use an enum, but CoreData requires a String
    func smileyImage(forNote note: Note) -> UIImage? {
        switch note.smiley {
        case "bad":
            return UIImage(named: "icn_bad")
        case "average":
            return UIImage(named: "icn_average")
        case "happy":
            return UIImage(named: "icn_happy")
        case "none":
            return nil
        default:
            return nil
        }
    }
    
}
