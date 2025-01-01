//
//  HomeViewModel.swift
//
//  Created by Ash Sharma on 12/1/24.
//

import Foundation
import SwiftUI
import MapKit

struct MenuSection: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let destination: AnyView
}

class HomeViewModel: ObservableObject {
    @Published var sections: [MenuSection] = []

    init() {
        sections = [
            MenuSection(
                name: "My Activity",
                description: "View your activity",
                icon: "figure.walk",
                destination: AnyView(MyActivityView())
            ),
            MenuSection(
                name: "Health Summary",
                description: "See your health data",
                icon: "heart.text.square",
                destination: AnyView(HealthSummaryView())
            ),
            MenuSection(
                name: "Goals",
                description: "Set your goals",
                icon: "target",
                destination: AnyView(GoalsView())
            ),
            MenuSection(
                name: "Personalized Workout Plan",
                description: "Get your workout plan",
                icon: "list.bullet",
                destination: AnyView(WorkoutPlanView())
            ),
            MenuSection(
                name: "Nearby Gyms & Parks",
                description: "Find gyms and parks",
                icon: "map",
                destination: AnyView(NearbyGymsView())
            ),
            MenuSection(
                name: "Healthy Recipes",
                description: "Discover healthy meals",
                icon: "fork.knife",
                destination: AnyView(MealsView())
            ),
            MenuSection(
                name: "Info",
                description: "Weight, Age, Sex",
                icon: "person.crop.circle",
                destination: AnyView(SettingsView())
            )
        ]
    }
}
