//
//  MealsView.swift
//  Project
//
//  Created by Ash Sharma on 12/1/24.


import SwiftUI

struct MealsView: View {
    @StateObject private var viewModel = MealsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.meals.isEmpty {
                    ProgressView("Loading Meals...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    List(viewModel.meals, id: \.mealID) { meal in
                        HStack {
                            if let url = URL(string: meal.thumbnail) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 63, height: 63)
                                .clipShape(Circle())
                            }
                            
                            // Meal Name
                            Text(meal.name)
                                .font(.headline)
                                .padding(.leading, 10)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Meals")
           
        }
    }
}


