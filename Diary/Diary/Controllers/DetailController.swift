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

   // var dataSource: [UIImage] = []
    @IBOutlet weak var selectedImage: UIImageView!
    
    lazy var dataSource: PhotoDataSource = {
        return PhotoDataSource(data: [], collectionView: self.photosCollectionView)
    }()
    
    lazy var photoPickerManager: PhotoPickerManager = {
        let manager = PhotoPickerManager(presentingViewController: self)
        manager.delegate = self
        return manager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Date().dateOfTheDay()
        photosCollectionView.dataSource = dataSource
        photosCollectionView.delegate = self
        configureView()
        
        selectedImage.layer.cornerRadius = selectedImage.frame.height/2
        selectedImage.clipsToBounds = true
    }
    
    
    func configureView() {
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
                    dataSource.appendData(photo.image)
                    if photo.isMainPhoto {
                        selectedImage.image = photo.image
                    }
                }
            }
            photosCollectionView.reloadData()
        }
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
        }
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
        
        if let text = textTextField.text {
            note.text = text
            note.modificationDate = dateFormatter.string(from: Date())
            note.longitude = coordinate.longitude
            note.latitude = coordinate.latitude
            note.locationDescription = locationDescription
            note.smiley = smiley
            if dataSource.numberOfElements() > 0 {
                var savedPhotos: [Photo] = []
                for image in dataSource.data {
                    var resizedImage = image
                    if !update {
                        let imageWidth = image.size.width
                        let imageHeight = image.size.height
                        let size = CGSize(width: imageWidth*0.25, height: imageHeight*0.25)
                        guard let image = image.resized(to: size) else { return }
                        resizedImage = image
                    }
                    if image == selectedImage.image {
                        savedPhotos.append(Photo.withImage(resizedImage, isMainPhoto: true, in: managedObjectContext))
                    } else {
                        savedPhotos.append(Photo.withImage(resizedImage, isMainPhoto: false, in: managedObjectContext))
                    }
                }
                note.photos = Set(savedPhotos)
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
            
            self.dataSource.appendData(image)
            
            self.managedObjectContext.saveChanges()
            
            self.photosCollectionView.reloadData()
            
        }
    }
    
}


extension DetailController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = dataSource.object(at: indexPath)
        
        if selectedImage.image == photo {
            selectedImage.image = UIImage(named: "icn_noimage_small")
        } else {
            selectedImage.image = photo
        }
    }
    
}
