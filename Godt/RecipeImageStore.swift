//
//  RecipeImageStore.swift
//  Godt
//
//  Created by Kweth on 5/29/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit

class RecipeImageStore: NSObject {
    
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String) {
        
        let imageURL = imageURLForKey(key)
        
        if let data = UIImagePNGRepresentation(image) {
            data.writeToURL(imageURL, atomically: true)
        }
        
        cache.setObject(image, forKey: key)
    }
    
    func imageForKey(key: String)->UIImage? {
        
        if let existingImage = cache.objectForKey(key) as? UIImage {
            return existingImage
        }
        
        let imageURL = imageURLForKey(key)
        
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObjectForKey(key)
        let imageURL = imageURLForKey(key)
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent(key)
    }
}

