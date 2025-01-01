//
//  ContentView.swift
//
//  Created by Ash Sharma on 11/1/24.
//



import SwiftUI
import MapKit

struct HomeView: View {
    @StateObject private var userSettingsViewModel = UserSettingsViewModel()
    @StateObject private var healthStoreViewModel = HealthStoreViewModel()
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(homeViewModel.sections) { section in
                    NavigationLink(destination: section.destination
                                    .environmentObject(userSettingsViewModel)
                                    .environmentObject(healthStoreViewModel)) {
                        HStack {
                            Image(systemName: section.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 28)
                            VStack(alignment: .leading, spacing: 7) {
                                Text(section.name)
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                Text(section.description)
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Fitness App")
        }
        .environmentObject(userSettingsViewModel)
        .environmentObject(healthStoreViewModel)
    }
}
