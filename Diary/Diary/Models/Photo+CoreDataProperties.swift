//
//  Photo+CoreDataProperties.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//
//

import UIKit
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "imageData", ascending: true)]

        return request
    }

    @NSManaged public var imageData: NSData
    
}

extension Photo {
    var image: UIImage {
        return UIImage(data: self.imageData as Data)!
    }
    
    @nonobjc class func withImage(_ image: UIImage, in context: NSManagedObjectContext) -> Photo {
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
        photo.imageData = image.jpegData(compressionQuality: 1.0) as! NSData
        return photo
    }
    

}
