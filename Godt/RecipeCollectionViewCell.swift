//
//  RecipeCollectionViewCell.swift
//  Godt
//
//  Created by Kweth on 5/20/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateWithImage(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        updateWithImage(nil)
    }
    
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
            
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
}


