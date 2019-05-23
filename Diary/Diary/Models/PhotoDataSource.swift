//
//  PhotoDataSource.swift
//  Diary
//
//  Created by davidlaiymani on 23/05/2019.
//  Copyright © 2019 davidlaiymani. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    var data: [UIImage]
    var collectionView: UICollectionView
    
    init(data: [UIImage], collectionView: UICollectionView) {
        self.data = data
        self.collectionView = collectionView
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        
        cell.image.image = object(at: indexPath)
        
        return cell
        
    }
    
    // MARK: Helpers functions
    func object(at indexPath: IndexPath) -> UIImage {
        return data[indexPath.row]
    }
    
    func appendData(_ data: UIImage) {
        self.data.append(data)
    }
    
    func numberOfElements() -> Int {
        return data.count
    }
}
