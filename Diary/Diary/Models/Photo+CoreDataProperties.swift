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



// The Photo Model. Photos are managed by CoreData
extension Photo {

    // Returns a request that fetches Photo objects
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "imageData", ascending: true)]

        return request
    }

    // A Photo = an image + a boolean indicating if the photo is the main photo i.e. the one that appears in the master Controller
    @NSManaged public var imageData: NSData
    @NSManaged public var isMainPhoto: Bool

}

extension Photo {
    var image: UIImage {
        return UIImage(data: self.imageData as Data)!
    }
    
    // Add a photo into a context
    @nonobjc class func withImage(_ image: UIImage, isMainPhoto: Bool, in context: NSManagedObjectContext) -> Photo {
        let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
        photo.imageData = image.jpegData(compressionQuality: 1.0) as! NSData
        photo.isMainPhoto = isMainPhoto
        return photo
    }    

}
