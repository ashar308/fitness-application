//
//  NearbyGymsView.swift
//
//  Created by Ash Sharma on 12/1/24.
//



import SwiftUI
import MapKit

struct NearbyGymsView: View {
    @StateObject private var nearbyGymsViewModel = NearbyGymsViewModel()

    var body: some View {
        Map(coordinateRegion: $nearbyGymsViewModel.region, annotationItems: nearbyGymsViewModel.landmarks) { landmark in
            MapAnnotation(coordinate: landmark.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(.title)
            }
        }
        .navigationTitle("Nearby Gyms & Parks")
        .alert(isPresented: $nearbyGymsViewModel.showAlert) {
            Alert(title: Text("Location Error"),
                  message: Text(nearbyGymsViewModel.alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}




