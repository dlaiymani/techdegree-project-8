//
//  PhotosFetchedResultsController.swift
//  Diary
//
//  Created by davidlaiymani on 22/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import CoreData

class PhotosFetchedResultsController: NSFetchedResultsController<Photo> {
    init(request: NSFetchRequest<Photo>, context: NSManagedObjectContext) {
        super.init(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetch()
    }
    
    func fetch() {
        do {
            try performFetch()
        } catch {
            fatalError()
        }
    }
}
