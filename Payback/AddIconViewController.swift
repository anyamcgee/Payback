//
//  addIconViewController.swift
//  Payback
//
//  Created by Anya McGee on 2015-12-12.
//  Copyright © 2015 Stacks of Cache. All rights reserved.
//

import UIKit

class AddIconViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var addGroupVC: AddGroupViewController?
    
    let iconNames: [String] = ["car223", "drink24", "house28", "japanese", "pizza3", "car189"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("iconCell", forIndexPath: indexPath) as? IconCollectionViewCell {
            cell.iconImage.image = UIImage(named: self.iconNames[indexPath.row])
            return cell
        } else {
            return IconCollectionViewCell()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let vc = self.addGroupVC {
            if let icon = (collectionView.cellForItemAtIndexPath(indexPath) as? IconCollectionViewCell)?.iconImage.image {
                vc.iconImageView.image = icon
                vc.iconName = self.iconNames[indexPath.row]
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.iconNames.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(80, 80)
    }

}
