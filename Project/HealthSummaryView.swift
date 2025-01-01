//
//  HealthSummaryView.swift
//
//  Created by Ash Sharma on 12/1/24.
//

import SwiftUI
import SwiftData

struct HealthSummaryView: View {
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        VStack {
            HStack {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }
            .padding()

            List(filteredActivities) { activity in
                VStack(alignment: .leading, spacing: 5) {
                    Text(activity.date, style: .date)
                        .font(.headline)
                    Text("Calories Intake: \(activity.caloriesIntake, specifier: "%.0f") kcal")
                    Text("Steps: \(activity.steps)")
                    Text("Water Intake: \(activity.waterIntake, specifier: "%.1f") L")
                    Text("Protein Intake: \(activity.proteinIntake, specifier: "%.0f") g")
                    Text("Calories Burned: \(activity.caloriesBurned, specifier: "%.0f") kcal")
                        .foregroundColor(.secondary)
                    if let sleep = activity.sleepHours {
                        Text("Sleep Hours: \(sleep, specifier: "%.1f") hrs")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Health Summary")
    }

    var filteredActivities: [Activity] {
        activities.filter { activity in
            activity.date >= startDate && activity.date <= endDate
        }
    }
}

