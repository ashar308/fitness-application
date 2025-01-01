//
//  NearbyGymsViewModel.swift
//  Project
//
//  Created by Ash Sharma on 12/3/24.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

class NearbyGymsViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var landmarks: [Landmark] = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }
    // Reference: https://medium.com/@desilio/getting-user-location-with-swiftui-1f79d23c2321
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showAlertMessage("Location access is restricted or denied. Please enable location services in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("User location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.updateRegion(with: location.coordinate)
            self.searchNearbyPlaces(query: "Gym")
        }
        locationManager.stopUpdatingLocation()
    }
    
    private func updateRegion(with coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    func searchNearbyPlaces(query: String) {
        guard !query.isEmpty else { return }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = region
        
        MKLocalSearch(request: searchRequest).start { [weak self] response, error in
            if let response = response {
                DispatchQueue.main.async {
                    self?.landmarks = response.mapItems.map { Landmark(placemark: $0.placemark) }
                }
            }
        }
    }
    private func showAlertMessage(_ message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }
}

