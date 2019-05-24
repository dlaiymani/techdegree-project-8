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
    
    
   // @IBOutlet weak var textTextField: UITextField!
    
    @IBOutlet weak var textTextField: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var averageButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var smileyImageView: UIImageView!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var coordinate = Coordinate(latitude: 0.0, longitude: 0.0)
    var locationDescription = "📍 No Location"
    var smiley = "none"
    var update:Bool = false // true if a cell has been tapped in the Master Controller
    
    var note: Note? // The note to create or to update

    @IBOutlet weak var selectedImage: UIImageView!
    
    // Data Source for the Image CollectionView
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
            
            // location info management
            locationLabel.text = note.locationDescription
            if (note.latitude != 0.0 && note.longitude != 0.0) {
                locationButton.setTitle(" Change Location", for: .normal)
            }
            self.coordinate = Coordinate(latitude: note.latitude, longitude: note.longitude)
            locationDescription = note.locationDescription
            
            // Smiley Management
            smiley = note.smiley
            displaySmiley()
            
            // Main photo management
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
    
    override func viewWillAppear(_ animated: Bool) {
        if (coordinate.latitude != 0.0 && coordinate.longitude != 0.0) {
            locationButton.setTitle(" Change Location", for: .normal)
        }
    }
    
    @IBAction func launchCamera(_ sender: Any) {
        photoPickerManager.presentPhotoPicker(animated: true)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // Svae button tapped
    @IBAction func save(_ sender: Any) {
        guard let text = textTextField.text, !text.isEmpty else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        // if update: delete the note and create a new one. Not sure it is the best way to do
        // but don't figure out to use the setValue methods
        if update {
            managedObjectContext.delete(self.note!)
        }
        
        // create a new note only if text is non empty
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
        
        if let text = textTextField.text {
            note.text = text
            note.modificationDate = dateFormatter.string(from: Date())
            note.longitude = coordinate.longitude
            note.latitude = coordinate.latitude
            note.locationDescription = locationDescription
            note.smiley = smiley
            if dataSource.numberOfElements() > 0 { // If there are photos
                var savedPhotos: [Photo] = []
                for image in dataSource.data {
                    let pngImage = image.pngData()
                    let pngSelectedImage = selectedImage.image?.pngData()
                    
                    // main photo management
                    if pngImage == pngSelectedImage {
                        savedPhotos.append(Photo.withImage(image, isMainPhoto: true, in: managedObjectContext))
                    } else {
                        savedPhotos.append(Photo.withImage(image, isMainPhoto: false, in: managedObjectContext))
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
    
    
    // MARK: Smiley management. Would be better with enum but CoreData requires String
    
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
            smileyImageView.image = nil
            smiley = "none"
        }
    }
    
    //MARK: - Navigation
    
    // back from location controller
    @IBAction func unwindFromLocationController(_ segue: UIStoryboardSegue) {
            self.locationLabel.text = "📍 \(locationDescription)"
    }
}


extension DetailController: PhotoPickerManagerDelegate {
    // An image has been picked
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        manager.dismissPhotoPicker(animated: true) {
            
            // Resizing of the image at a lower size
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            let size = CGSize(width: imageWidth*0.25, height: imageHeight*0.25)
            guard let resizedImage = image.resized(to: size) else { return }
            
            self.dataSource.appendData(resizedImage)
            
            self.photosCollectionView.reloadData()
            
        }
    }
    
}


extension DetailController: UICollectionViewDelegate {
    
    // An image has been tapped in the CollectionView -> main image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photo = dataSource.object(at: indexPath)
        
        if selectedImage.image == photo {
            selectedImage.image = UIImage(named: "icn_noimage_small")
        } else {
            selectedImage.image = photo
        }
    }
    
}
