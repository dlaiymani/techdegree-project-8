//
//  PhotosDataSource.swift
//  Diary
//
//  Created by davidlaiymani on 22/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit
import CoreData

class PhotosDataSource: NSObject, UICollectionViewDataSource {
    private let collectionView: UICollectionView
    private let fetchedResultsController: PhotosFetchedResultsController
    
    init(fetchRequest: NSFetchRequest<Photo>, managedObjectContext context: NSManagedObjectContext, collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.fetchedResultsController = PhotosFetchedResultsController(request: fetchRequest, context: context)
        super.init()
        
        self.fetchedResultsController.delegate = self
    }
    
    
    func object(at indexPath: IndexPath) -> Photo {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as! ImageCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        photoCell.image.image = photo.image
        
        return photoCell
    }
}

extension PhotosDataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("yo")
        collectionView.reloadData()
    }
}

extension PhotosDataSource {
    var photos: [Photo] {
        guard let objects = fetchedResultsController.sections?.first?.objects as? [Photo] else {
            return []
        }
        
        return objects
    }
}
