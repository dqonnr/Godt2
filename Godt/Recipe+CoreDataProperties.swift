//
//  Recipe+CoreDataProperties.swift
//  Godt
//
//  Created by Kweth on 5/29/16.
//  Copyright © 2016 Kweth. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Recipe {

    @NSManaged var detail: String
    @NSManaged var ingredients: [String]
    @NSManaged var photoURL: NSURL
    @NSManaged var title: String
    @NSManaged var recipeID: Int
    @NSManaged var recipeKey: String

}
