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
    
    var managedObjectContext: NSManagedObjectContext!
    
    var coordinate: Coordinate?
    var locationDescription: String?
    var smiley = "none"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Date().dateOfTheDay()
        

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
            note.text = text
            note.modificationDate = NSDate()
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
