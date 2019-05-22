//
//  Note+CoreDataProperties.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {

        let request = NSFetchRequest<Note>(entityName: "Note")
        request.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]

        return request
    }
    

    @NSManaged public var latitude: Double // can figure out to put these properties optional
    @NSManaged public var longitude: Double
    @NSManaged public var modificationDate: String
    @NSManaged public var text: String
    @NSManaged public var locationDescription: String
    @NSManaged public var smiley: String?
    @NSManaged public var photos: Photo?

}

extension Note {
    
    class func with(_ note: Note, photo: UIImage, in context: NSManagedObjectContext) -> Note {
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! Note
        
        newNote.latitude = note.latitude
        newNote.longitude = note.longitude
        newNote.modificationDate = note.modificationDate
        newNote.text = note.text
        newNote.locationDescription = note.locationDescription
        newNote.smiley = note.smiley
       // newNote.photos = Photo.withImage(photo, in: context)
       
        return newNote
    }
    
    
}
