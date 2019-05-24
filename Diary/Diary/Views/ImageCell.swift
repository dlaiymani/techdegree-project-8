//
//  ImageCell.swift
//  Diary
//
//  Created by davidlaiymani on 22/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit

// The collectioview cell of the DetailController for displaying Photos
class ImageCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ImageCell.self)

    @IBOutlet weak var image: UIImageView!
    
}
