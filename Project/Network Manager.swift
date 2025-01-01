//
//  Network Manager.swift
//  Project
//
//  Created by Ash Sharma on 12/1/24.
//


import Foundation

class NetworkManager {
    // Singleton instance for global access
    static let shared = NetworkManager()
    
    // Private initializer to enforce singleton usage
    private init() {}

    func fetchMeals(completion: @escaping ([Meal]?) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
            if let mealsResponse = try? JSONDecoder().decode(MealsResponse.self, from: data) {
                    let meals = mealsResponse.meals.map { mealResponse in
                        Meal(
                            mealID: mealResponse.idMeal,
                            name: mealResponse.strMeal,
                            category: "",
                            area: "",
                            instructions: "",
                            thumbnail: mealResponse.strMealThumb,
                            tags: nil,
                            youtubeURL: nil
                        )
                    }
                    completion(meals)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
}
