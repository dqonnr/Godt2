//
//  Recipe.swift
//  Godt
//
//  Created by Kweth on 5/24/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit
import CoreData

class Recipe: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var image: UIImage?
    
    override func awakeFromInsert() {
        
        title = ""
        recipeID = -1
        detail = ""
        ingredients = []
        photoURL = NSURL()
        recipeKey = NSUUID().UUIDString
    }
}
