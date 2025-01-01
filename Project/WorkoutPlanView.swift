//
//  WorkoutPlanView.swift
//
//  Created by Ash Sharma on 12/1/24.
//

import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel

    let muscleGroups = ["Chest", "Legs", "Back", "Shoulders", "Abs", "Arms"]

    var body: some View {
        List(muscleGroups, id: \.self) { group in
            NavigationLink(destination: ExerciseListView(muscleGroup: group, isCutting: userSettingsViewModel.weight > 85)) {
                Text(group)
            }
        }
        .navigationTitle("Workout Plan")
    }
}
