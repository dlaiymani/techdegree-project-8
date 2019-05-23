//
//  DetailControllerViewController.swift
//  Diary
//
//  Created by davidlaiymani on 21/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DetailController: UIViewController {
    
    
    @IBOutlet weak var textTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var averageButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var smileyImageView: UIImageView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
    var locationDescription = "📍 No Location"
    var smiley = "none"
    
    var update:Bool = false
    
    var note: Note?

    var dataSource: [UIImage] = []
    @IBOutlet weak var selectedImage: UIImageView!
    
    
//    lazy var dataSource: PhotosDataSource = {
//        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
//        return PhotosDataSource(fetchRequest: request, managedObjectContext: self.managedObjectContext, collectionView: self.photosCollectionView)
//    }()

    
    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingViewController: self)
        manager.delegate = self
        return manager
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Date().dateOfTheDay()
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        locationLabel.text = locationDescription
        
        if let note = note {
            textTextField.text = note.text
            locationLabel.text = note.locationDescription
                
            self.coordinate = Coordinate(latitude: note.latitude, longitude: note.longitude)
            if let smiley = note.smiley {
                self.smiley = smiley
                displaySmiley()
            }
            if let photos = note.photos {
                for photo in photos {
                    dataSource.append(photo.image)
                    if photo.isMainPhoto {
                        selectedImage.image = photo.image
                    }
                }
            }
            photosCollectionView.reloadData()
            
        }
        
        selectedImage.layer.cornerRadius = selectedImage.frame.height/2
        selectedImage.clipsToBounds = true
    }
    
    
    @IBAction func launchCamera(_ sender: Any) {
        photoPickerManager.presentPhotoPicker(animated: true)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func save(_ sender: Any) {
        guard let text = textTextField.text, !text.isEmpty else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        if update {
            
            managedObjectContext.delete(self.note!)
//            self.note?.setValue(text, forKey: "text")
//            self.note?.setValue(dateFormatter.string(from: Date()), forKey: "modificationDate")
//            self.note?.setValue(coordinate.latitude, forKey: "latitude")
//            self.note?.setValue(coordinate.longitude, forKey: "longitude")
//            self.note?.setValue(locationDescription, forKey: "locationDescription")
//            self.note?.setValue(smiley, forKey: "smiley")
//
//            var savedPhotos: [Photo] = []
//            for image in dataSource {
//                if image == selectedImage.image {
//                    savedPhotos.append(Photo.withImage(image, isMainPhoto: true, in: managedObjectContext))
//                } else {
//                    savedPhotos.append(Photo.withImage(image, isMainPhoto: false, in: managedObjectContext))
//                }
//            }
//            self?.note.setValue(Set(savedPhotos), forKet: "photos")
            
//            if images.count > 0 {
//
//                var savedPhotos: [Photo] = []
//                for image in images {
//                    if image == selectedImage.image {
//                        savedPhotos.append(Photo.withImage(image, isMainPhoto: true, in: managedObjectContext))
//                    } else {
//                        savedPhotos.append(Photo.withImage(image, isMainPhoto: false, in: managedObjectContext))
//                    }
//                }
//
//                self.note?.setValue(Set(savedPhotos), forKey: "photos")
//
//            } else {
//                self.note?.setValue(nil, forKey: "photos")
//            }
            
        }
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
            
            if let text = textTextField.text {
                note.text = text
                note.modificationDate = dateFormatter.string(from: Date())
                note.longitude = coordinate.longitude
                note.latitude = coordinate.latitude
                note.locationDescription = locationDescription
                note.smiley = smiley
                if dataSource.count > 0 {
                    print(dataSource.count)

                    var savedPhotos: [Photo] = []
                    for image in dataSource {
                        if image == selectedImage.image {
                            savedPhotos.append(Photo.withImage(image, isMainPhoto: true, in: managedObjectContext))
                        } else {
                            savedPhotos.append(Photo.withImage(image, isMainPhoto: false, in: managedObjectContext))
                        }
                    }
                    note.photos = Set(savedPhotos)
//                    if let mainImage = selectedImage.image {
//                        note.mainPhoto = Photo.withImage(mainImage, in: managedObjectContext)
//                    }
                    //note.photos = Photo.withImage(images[0], in: managedObjectContext
                } else {
                    note.photos = nil
                }
            }
        
        managedObjectContext.saveChanges() 
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func displaySmiley() {
        switch smiley {
        case "bad":
            smileyImageView.image = UIImage(named: "icn_bad")
        case "average":
            smileyImageView.image = UIImage(named: "icn_average")
        case "happy":
            smileyImageView.image = UIImage(named: "icn_happy")
        case "none":
            smileyImageView.image = nil
        default:
            break
        }
    }
    
    @IBAction func smileyTapped(_ sender: UIButton) {
        switch  sender {
        case badButton:
            if smiley == "bad" {
                smileyImageView.image = nil
                smiley = "none"
            } else {
                smileyImageView.image = UIImage(named: "icn_bad")
                smiley = "bad"
            }
        case averageButton:
            if smiley == "average" {
                smileyImageView.image = nil
                smiley = "none"
            } else {
                smileyImageView.image = UIImage(named: "icn_average")
                smiley = "average"
            }
        case goodButton:
            if smiley == "happy" {
                smileyImageView.image = nil
                smiley = "none"
            } else {
                smileyImageView.image = UIImage(named: "icn_happy")
                smiley = "happy"
            }

        default:
            break
        }
    }
    
    @IBAction func unwindFromLocationController(_ segue: UIStoryboardSegue) {
            self.locationLabel.text = "📍 \(locationDescription)"
    }
}


extension DetailController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        manager.dismissPhotoPicker(animated: true) {
            
           // let photo = Photo.withImage(image, isMainPhoto: true, in: self.managedObjectContext)
          //  self.note?.photos?.insert(photo)
            self.dataSource.append(image)
            
            self.managedObjectContext.saveChanges()
            
          //  self.images.append(photo)
            self.photosCollectionView.reloadData()
            
        }
    }
    
}



extension DetailController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell

        cell.image.image = dataSource[indexPath.row]

        return cell
        
    }
}

extension DetailController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let image = images[indexPath.row]
        
        let photo = dataSource[indexPath.row]
        
//        note?.photos?.remove(photo)
//        photo.isMainPhoto = true
//        note?.photos?.insert(photo)
       // photo.setValue(true, forKey: "isMainPhoto")
      //  managedObjectContext.saveChanges()
        
        if selectedImage.image == photo {
            selectedImage.image = UIImage(named: "icn_noimage_small")
        } else {
            selectedImage.image = photo
        }
    }
    
}
