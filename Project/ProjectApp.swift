//
//  ProjectApp.swift
//  Created by Ash Sharma on 11/1/24.
//

import SwiftUI
import SwiftUI
import SwiftData

@main
struct FitnessApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Activity.self])
    }
}

