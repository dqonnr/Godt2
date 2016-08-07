//
//  RecipeStore.swift
//  Godt
//
//  Created by Kweth on 5/13/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class RecipeStore {
    
    let imageStore = RecipeImageStore()
    let coreDataStack = CoreDataStack(modelName: "Godt")
    
    var recipes: [Recipe]?
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func fetchRecentRecipes(completion completion: (RecipesResult) -> Void) {
        let url = GodtAPI.recentRecipesURL()
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            if let jsonData = data {
                do {
                    let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
                    print(jsonObject)
                }
                catch let error {
                    print("Error creating json object: \(error)")
                }
          
            } else if let requestError = error {
                print("Error fetching recent recipes: \(requestError)")
            } else {
                print("Unexpected error with the request")
            }
            
            //let result = self.processRecentRecipesRequest(data: data, error: error)
            
            var result = self.processRecentRecipesRequest(data: data, error: error)
            
            if case .Success(_) = result {
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueRecipes = try self.fetchMainQueueRecipes(predicate: nil, sortDescriptors: nil)
                    result = .Success(mainQueueRecipes)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
                
            completion(result)
        }
        
        task.resume()
    }
    
    func processRecentRecipesRequest(data data: NSData?, error: NSError?) -> RecipesResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        
        return GodtAPI.recipesFromJSONData(jsonData, inContext: coreDataStack.mainQueueContext)
    }
    
    func fetchImageForRecipe(recipe: Recipe, completion: (ImageResult) -> Void) {
        
        let recipeKey = recipe.recipeKey
        
        if let image = imageStore.imageForKey(recipeKey) {
            recipe.image = image
            completion(.Success(image))
            return
        }
        
        let photoURL = recipe.photoURL
        
        let request = NSURLRequest(URL: photoURL)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
                recipe.image = image
                self.imageStore.setImage(image, forKey: recipe.recipeKey)
            }
            
            completion(result)
        }
        
        task.resume()
    }
    
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                
                if data == nil {
                    return .Failure(error!)
                } else {
                    return .Failure(PhotoError.ImageCreationError)
                }
        }
        
        return .Success(image)
    }
    
    func fetchMainQueueRecipes(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Recipe] {
        
        let fetchRequest = NSFetchRequest(entityName: "Recipe")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        var mainQueueRecipes: [Recipe]?
        var fetchRequestError: ErrorType?
        let mainQueueContext = coreDataStack.mainQueueContext
        
        mainQueueContext.performBlockAndWait() {
            
            do {
                mainQueueRecipes = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Recipe]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let recipes = mainQueueRecipes else {
            throw fetchRequestError!
        }
        
        return recipes
    }
}