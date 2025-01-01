//
//  Modal.swift
//
//  Created by Ash Sharma on 11/1/24.
//


import Foundation
import SwiftData
import MapKit

@Model
class Activity: Identifiable {
    @Attribute var date: Date
    @Attribute var caloriesIntake: Double
    @Attribute var steps: Int
    @Attribute var waterIntake: Double
    @Attribute var proteinIntake: Double
    @Attribute var caloriesBurned: Double
    @Attribute var sleepHours: Double?
    
    init(date: Date, caloriesIntake: Double, steps: Int, waterIntake: Double, proteinIntake: Double, caloriesBurned: Double, sleepHours: Double? = nil) {
        self.date = date
        self.caloriesIntake = caloriesIntake
        self.steps = steps
        self.waterIntake = waterIntake
        self.proteinIntake = proteinIntake
        self.caloriesBurned = caloriesBurned
        self.sleepHours = sleepHours
    }
}

struct Landmark: Identifiable {
    let id = UUID()
    let placemark: MKPlacemark
    
    var coordinate: CLLocationCoordinate2D {
        placemark.coordinate
    }
}

struct Meal: Codable, Identifiable {
    let id = UUID()
    let mealID: String
    let name: String
    let category: String
    let area: String
    let instructions: String
    let thumbnail: String
    let tags: String?
    let youtubeURL: String?
    
    enum CodingKeys: String, CodingKey {
        case mealID = "idMeal"
        case name = "strMeal"
        case category = "strCategory"
        case area = "strArea"
        case instructions = "strInstructions"
        case thumbnail = "strMealThumb"
        case tags = "strTags"
        case youtubeURL = "strYoutube"
    }
}



struct MealsResponse: Codable {
    let meals: [MealSummary]
}

struct MealSummary: Codable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
}
