//
//  SettingsView.swift
//
//  Created by Ash Sharma on 12/1/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var userSettingsViewModel: UserSettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var weightInput: String = ""
    @State private var age: String = ""
    @State private var sex: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                HStack{
                    Text("Weight (kg): ")
                    TextField("Weight (kg)", text: $weightInput)
                }
                HStack{
                    Text("Age: ")
                    TextField("Enter Age", text: $age)
                    
                }
                HStack{
                    Text("Sex: ")
                    TextField("Enter Sex", text: $sex)
                    
                }
                
            }
            
            Section {
                Button("Save") {
                    print("Entered save")
                    if let weight = Double(weightInput) {
                        userSettingsViewModel.weight = weight
                        print("weight is: ")
                        print(weight)
                        dismiss()
                    }
                }
                
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            weightInput = userSettingsViewModel.weight > 0 ? "\(userSettingsViewModel.weight)" : ""
        }
    }
}

