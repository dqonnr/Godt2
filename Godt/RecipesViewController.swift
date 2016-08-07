//
//  RecipesViewController.swift
//  Godt
//
//  Created by Kweth on 5/13/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit

class RecipesViewController: UIViewController, UICollectionViewDelegate {

    var store: RecipeStore!
    
    @IBOutlet var collectionView: UICollectionView!
    
    let recipeDataSource = RecipeDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.collectionView.dataSource = recipeDataSource
        self.collectionView.delegate = self
        
        store.fetchRecentRecipes() {
            (recipesResult) -> Void in
            
//            NSOperationQueue.mainQueue().addOperationWithBlock() {
//                switch recipesResult {
//                case let .Success(recipes):
//                    print("Successfully fetched \(recipes.count) recent recipes.")
//                    self.recipeDataSource.recipes = recipes
//                case let .Failure(error):
//                    self.recipeDataSource.recipes.removeAll()
//                    print("Error fetching recent recipes: \(error)")
//                }
//                self.collectionView.reloadSections(NSIndexSet(index: 0))
//            }
            
            let allRecipes = try! self.store.fetchMainQueueRecipes(predicate: nil, sortDescriptors: nil)
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.recipeDataSource.recipes = allRecipes
                self.collectionView.reloadSections(NSIndexSet(index: 0))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let recipe = recipeDataSource.recipes[indexPath.row]
        
        store.fetchImageForRecipe(recipe) {
            (result) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                let recipeIndex = self.recipeDataSource.recipes.indexOf(recipe)!
                let recipeIndexPath = NSIndexPath(forRow: recipeIndex, inSection: 0)
                
                if let cell = collectionView.cellForItemAtIndexPath(recipeIndexPath) as? RecipeCollectionViewCell {
                    cell.updateWithImage(recipe.image)
                }

            }
            
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowRecipe" {
            
            if let selectedRecipe = collectionView.indexPathsForSelectedItems()?.first {
                
                let recipe = recipeDataSource.recipes[selectedRecipe.row]
                let destanationVC = segue.destinationViewController as! RecipeInfoViewController
                
                destanationVC.store = store
                destanationVC.recipe = recipe
            }
        }
    }

}