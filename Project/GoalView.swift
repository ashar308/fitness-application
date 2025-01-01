//
//  GoalDetailView.swift
//
//  Created by Ash Sharma on 11/29/24.

import SwiftUI
import SwiftData

struct GoalsView: View {
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @Query(sort: \Activity.date, order: .reverse) private var allActivities: [Activity]
    @StateObject private var goalsViewModel = GoalsViewModel()

    var body: some View {
        Form {
            Section(header: Text("Set Your Weekly Goals")) {
                HStack{
                    Text("Weekly Step Goal: ")
                    TextField("Weekly Step Goal", text: $goalsViewModel.weeklyStepInput)
                }
                HStack{
                Text("Weekly Calories Goal (kcal): ")
                TextField("Weekly Calories Goal (kcal)", text: $goalsViewModel.goalCaloriesInput)
                }
                 
            }
            Section {
                Button("Save Goals") {
                    goalsViewModel.changeGoals()
                }
            }
            Section(header: Text("Progress Over Last 7 Days")) {
                ProgressView(value: goalsViewModel.totalStepsOverLastWeek, total: Double(userSettingsViewModel.weeklyStepGoal))
                Text("Total Steps: \(Int(goalsViewModel.totalStepsOverLastWeek)) / \(userSettingsViewModel.weeklyStepGoal)")

                ProgressView(value: goalsViewModel.totalCaloriesOverLastWeek, total: userSettingsViewModel.weeklyCaloriesGoal)
                Text("Total Calories: \(Int(goalsViewModel.totalCaloriesOverLastWeek)) kcal / \(Int(userSettingsViewModel.weeklyCaloriesGoal)) kcal")
            }
        }
        .navigationTitle("Goals")
        .onAppear {
            goalsViewModel.userSettingsViewModel = userSettingsViewModel
            goalsViewModel.allActivities = allActivities
            goalsViewModel.calculateTotals()
        }
        .onChange(of: allActivities) { newActivities in
            goalsViewModel.allActivities = newActivities
            goalsViewModel.calculateTotals()
        }
    }
}
