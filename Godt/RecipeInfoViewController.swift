//
//  RecipeInfoViewController.swift
//  Godt
//
//  Created by Kweth on 5/21/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit

class RecipeInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detail: UILabel!
    @IBOutlet var ingredientsLabel: UILabel!
    
    var recipe: Recipe! {
        didSet {
            navigationItem.title = recipe.title
        }
    }
    
    var store: RecipeStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detail.text = recipe.detail.stringByReplacingOccurrencesOfString("<br />", withString: "")
        ingredientsLabel.text = recipe.ingredients.joinWithSeparator(" | ")
        
        store.fetchImageForRecipe(recipe) {
            (result) -> Void in
            
            switch result {
            case let .Success(image):
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.imageView.image = image
                }
            case let .Failure(error):
                print("Error fetching image for recipe: \(error)")
            }
        }
    }
}
