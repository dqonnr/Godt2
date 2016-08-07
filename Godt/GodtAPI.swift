//
//  GodtAPI.swift
//  Godt
//
//  Created by Kweth on 5/13/16.
//  Copyright © 2016 Kweth. All rights reserved.
//

import Foundation
import CoreData

enum RecipesResult {
    case Success([Recipe])
    case Failure(ErrorType)
}

enum GodtError: ErrorType {
    case InvalidJSONData
}

struct GodtAPI {
    
    private static let baseURLString = "http://www.godt.no/api/getRecipesListDetailed?tags=&size=thumbnail-medium&ratio=1&limit=20&from=0"
    
    static func recentRecipesURL() -> NSURL {
        let components = NSURLComponents(string: baseURLString)!
        
        return components.URL!
    }
    
    static func recipesFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> RecipesResult {
        
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let jsonArray = jsonObject as? [NSObject] else {
                return .Failure(GodtError.InvalidJSONData)
            }
            
            var finalRecipes = [Recipe]()
            
            for recipeJSON in jsonArray {
                
                if let recipe = recipeFromJSONObject(recipeJSON as! [String : AnyObject], inContext: context) {
                    finalRecipes.append(recipe)
                }
            }
            
            if finalRecipes.count == 0 && jsonArray.count > 0 {
                return .Failure(GodtError.InvalidJSONData)
            }
            
            return .Success(finalRecipes)
        }
        catch let error {
            return .Failure(error)
        }
    }
    
    private static func recipeFromJSONObject(json: [String : AnyObject], inContext context: NSManagedObjectContext) -> Recipe? {
        
        guard let
            title = json["title"] as? String,
            recipeID = json["id"] as? Int,
            detail = json["description"] as? String,
            images = json["images"] as? [[String:AnyObject]],
            firstImage = images.first,
            imageURLString = firstImage["url"] as? String,
            imageURL = NSURL(string: imageURLString),
            
            jsonIngredients = json["ingredients"] as? [[String:AnyObject]],
            firstIngredients = jsonIngredients.first,
            jsonIngredientsElements = firstIngredients["elements"] as? [[String:AnyObject]]
            // Other parameters go here
        else {
                // Don't have enough information to construct a Recipe
                return nil
        }
        
        var ingredients = [String]()
        for element in jsonIngredientsElements {
            if let name = element["name"] as? String {
                ingredients.append(name)
            }
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Recipe")

        let predicate = NSPredicate(format: "recipeID == \(recipeID)")
        fetchRequest.predicate = predicate
        
        var fetchedRecipes: [Recipe]!
        
        context.performBlockAndWait() {
            fetchedRecipes = try! context.executeFetchRequest(fetchRequest) as! [Recipe]
        }
        
        if fetchedRecipes.count > 0 {
            return fetchedRecipes.first
        }
        
        var recipe: Recipe!
        
        context.performBlockAndWait() {
            
            recipe = NSEntityDescription.insertNewObjectForEntityForName("Recipe", inManagedObjectContext: context) as! Recipe
            recipe.title = title
            recipe.recipeID = recipeID
            recipe.photoURL = imageURL
            recipe.detail = detail
            recipe.ingredients = ingredients
        }
        
        return recipe
        //return Recipe(title: title, detail: detail, photoURL: imageURL, ingredients: ingredients)
    }
}

