//
//  NoteFetchResultsController.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NoteFetchResultsController: NSFetchedResultsController<Note>, NSFetchedResultsControllerDelegate {
    
    private let tableView: UITableView
    private var nbOfSections = 0
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        
        super.init(fetchRequest: Note.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: "modificationDate", cacheName: nil)
        
        self.delegate = self
        
        tryFetch()
    }
    
    
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - FetchResultController Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        nbOfSections = self.sections!.count

    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }

            if self.sections?[newIndexPath.section].numberOfObjects == 1 {
                let indexSet = IndexSet(integer: newIndexPath.section)
                tableView.insertSections(indexSet, with: .fade)
            }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            if self.sections!.count < nbOfSections {
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.deleteSections(indexSet, with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update, .move:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
