//
//  AddActivityView.swift
//
//  Created by Ash Sharma on 12/1/24.
//

import SwiftUI
import SwiftData

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var date = Date()
    @State private var caloriesIntake: Double = 0.0
    @State private var steps: Int = 0
    @State private var waterIntake: Double = 0.0
    @State private var proteinIntake: Double = 0.0
    @State private var sleepHours: Double? = nil

    var body: some View {
        Form {
            Section(header: Text("Enter Activity Data")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                HStack{
                    Text("Please Enter Calories Intake (kcal): ")
                    TextField("Calories Intake (kcal)", value: $caloriesIntake, format: .number)
                    
                }
                HStack{
                    Text("Steps: ")
                    TextField("Steps", value: $steps, format: .number)
                    
                }
                HStack{
                    Text("Water Intake (L) ")
                    TextField("Water Intake (L)", value: $waterIntake, format: .number)
                    
                }
                HStack{
                    Text("Protein Intake (g) ")
                    TextField("Protein Intake (g)", value: $proteinIntake, format: .number)
                }
               
                HStack{
                    Text("Sleep Hours (hrs) ")
                    TextField("Sleep Hours (hrs)", value: $sleepHours, format: .number)
                    
                }
                
            }
        }
        .navigationTitle("Add Activity")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let caloriesBurned: Double = calculateCaloriesBurned(steps: steps)
                    let newActivity = Activity(
                        date: date,
                        caloriesIntake: caloriesIntake,
                        steps: steps,
                        waterIntake: waterIntake,
                        proteinIntake: proteinIntake,
                        caloriesBurned: caloriesBurned,
                        sleepHours: sleepHours
                    )
                    context.insert(newActivity)
                    dismiss()
                }
                .disabled(caloriesIntake <= 0 || steps < 0 || waterIntake <= 0 || proteinIntake < 0)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private func calculateCaloriesBurned(steps: Int) -> Double {
        let caloriesPerStep = 0.04
        return Double(steps) * caloriesPerStep
    }
}
