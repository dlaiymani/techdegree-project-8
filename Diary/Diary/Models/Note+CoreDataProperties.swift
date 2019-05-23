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
    @NSManaged public var smiley: String
    @NSManaged public var photos: Set<Photo>?
    @NSManaged public var mainPhoto: Photo?

}

