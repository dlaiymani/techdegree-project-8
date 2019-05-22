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
    
    var coordinate: Coordinate?
    var locationDescription: String?
    var smiley = "none"

    var images: [UIImage] = []
    @IBOutlet weak var selectedImage: UIImageView!
    
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
        
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: managedObjectContext) as! Note
        
        if let text = textTextField.text, let coordinate = coordinate {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            note.text = text
            note.modificationDate = dateFormatter.string(from: Date())
            note.longitude = coordinate.longitude
            note.latitude = coordinate.latitude
            note.locationDescription = locationDescription
            note.smiley = smiley
            managedObjectContext.saveChanges() // save the context on disk
        
            dismiss(animated: true, completion: nil)
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
        if let locationDescription = locationDescription {
            self.locationLabel.text = "📍 \(locationDescription)"
        }
    }
    
}


extension DetailController: PhotoPickerManagerDelegate {
    
    func manager(_ manager: PhotoPickerManager, didPickImage image: UIImage) {
        
        //        let _ = Photo.with(image, in: context)
        //        context.saveChanges()
        
        manager.dismissPhotoPicker(animated: true) {

            self.images.append(image)
            self.photosCollectionView.reloadData()
         //   self.dismiss(animated: true, completion: nil)
            
//            photoFilterController.managedObjectContext = self.context
//            let navController = UINavigationController(rootViewController: photoFilterController)
//            self.navigationController?.present(navController, animated: true, completion: nil)
        }
    }
    
}



extension DetailController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(images.count)
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.image.image = images[indexPath.row]
        
        return cell
        
    }
}

extension DetailController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        if selectedImage.image == image {
            selectedImage.image = UIImage(named: "icn_noimage_small")
        } else {
            selectedImage.image = image
        }
    }
    
}
