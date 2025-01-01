//
//  ExerciseListView.swift
//  Project
//
//  Created by Aishwary Sharma on 12/1/24.
//

import SwiftUI

struct ExerciseListView: View {
    let muscleGroup: String
    let isCutting: Bool

    var body: some View {
        List(exercisesForGroup(), id: \.self) { exercise in
            Text(exercise)
        }
        .navigationTitle("\(muscleGroup) Exercises")
    }

    func exercisesForGroup() -> [String] {
        var exercises: [String] = []

        switch muscleGroup {
        case "Chest":
            exercises = isCutting ? ["Push-Ups", "Incline Dumbbell Press", "Chest Flyes"] : ["Bench Press", "Dumbbell Press", "Cable Crossovers"]
        case "Legs":
            exercises = isCutting ? ["Bodyweight Squats", "Lunges", "Leg Extensions"] : ["Barbell Squats", "Deadlifts", "Leg Press"]
        case "Back":
            exercises = isCutting ? ["Pull-Ups", "Seated Cable Rows", "Hyperextensions"] : ["Deadlifts", "Bent Over Rows", "Lat Pulldowns"]
        case "Shoulders":
            exercises = isCutting ? ["Lateral Raises", "Front Raises", "Reverse Flyes"] : ["Military Press", "Arnold Press", "Upright Rows"]
        case "Abs":
            exercises = ["Crunches", "Planks", "Bicycle Kicks"]
        case "Arms":
            exercises = isCutting ? ["Triceps Pushdowns", "Hammer Curls", "Dips"] : ["Barbell Curls", "Skull Crushers", "Close Grip Bench Press"]
        default:
            exercises = []
        }

        return exercises
    }
}
