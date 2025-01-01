//
//  MyActivityView.swift
//
//  Created by Ash Sharma on 12/1/24.
//



import SwiftUI
import SwiftData

struct MyActivityView: View {
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @EnvironmentObject var healthStoreViewModel: HealthStoreViewModel

    @Query(sort: \Activity.date, order: .reverse) private var allActivities: [Activity]
    @State private var showAddActivitySheet = false

    @StateObject private var viewModel = MyActivityViewModel(healthStoreViewModel: nil, userSettingsViewModel: nil)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Activity")
                        .font(.title2)
                        .bold()

                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "figure.walk.circle.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.blue)
                            Text("\(viewModel.stepsToDisplay())")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Steps")
                                .font(.headline)
                        }

                        VStack {
                            Image(systemName: "flame.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text("\(Int(viewModel.caloriesToDisplay())) kcal")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Calories Burned")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Sleep Analysis")
                        .font(.title2)
                        .bold()

                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "bed.double.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.purple)
                            Text(viewModel.sleepTimeToDisplay())
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Sleep Duration")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Recommendations")
                        .font(.title2)
                        .bold()

                    if userSettingsViewModel.weight > 0 {
                        HStack(spacing: 20) {
                            VStack {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                Text("\(viewModel.waterRecommendation, specifier: "%.1f") L")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Water Intake")
                                    .font(.headline)
                            }
                            VStack {
                                Image(systemName: "leaf.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                Text("\(viewModel.proteinRecommendation, specifier: "%.0f") g")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Protein Intake")
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    } else {
                        Text("Please enter your weight to see recommendations.")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)

                // Today's Logged Activities
                if viewModel.activitiesForToday.isEmpty {
                    Text("No activities recorded for today.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Logged Activities")
                            .font(.title2)
                            .bold()
                            .padding(.leading)
                        ForEach(viewModel.activitiesForToday) { activity in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(activity.date, style: .time)
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
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("My Activity")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddActivitySheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddActivitySheet) {
            NavigationStack {
                AddActivityView()
            }
        }
        .onAppear {
            healthStoreViewModel.requestAuthorization()
            viewModel.healthStoreViewModel = healthStoreViewModel
            viewModel.userSettingsViewModel = userSettingsViewModel
            viewModel.allActivities = allActivities
        }
        .onChange(of: allActivities) { newActivities in
            viewModel.allActivities = newActivities
        }
    }
}
