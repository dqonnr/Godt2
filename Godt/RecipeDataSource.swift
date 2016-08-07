//
//  RecipeDataSource.swift
//  Godt
//
//  Created by Kweth on 5/20/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit

class RecipeDataSource: NSObject, UICollectionViewDataSource {
    var recipes = [Recipe]()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCell", forIndexPath: indexPath) as! RecipeCollectionViewCell
        
        let recipe = recipes[indexPath.row]
        cell.updateWithImage(recipe.image)
        
        return cell
    }
}
