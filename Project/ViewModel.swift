//
//  ViewModel.swift
//
//  Created by Ash Sharma on 11/1/24.


import SwiftUI
import Combine
import HealthKit
import SwiftData

class UserSettingsViewModel: ObservableObject {
    @Published var weight: Double {
        didSet {
            UserDefaults.standard.set(weight, forKey: "userWeight")
            print("Weight updated to: \(weight)")
        }
    }
    
    @Published var weeklyStepGoal: Int {
        didSet {
            UserDefaults.standard.set(weeklyStepGoal, forKey: "weeklyStepGoal")
        }
    }
    
    @Published var weeklyCaloriesGoal: Double {
        didSet {
            UserDefaults.standard.set(weeklyCaloriesGoal, forKey: "weeklyCaloriesGoal")
        }
    }


    init() {
        self.weight = UserDefaults.standard.double(forKey: "userWeight")
        self.weeklyStepGoal = UserDefaults.standard.integer(forKey: "weeklyStepGoal")
        self.weeklyCaloriesGoal = UserDefaults.standard.double(forKey: "weeklyCaloriesGoal")
    }
}





class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var errormsg: String? = nil
    
    init() {
        fetchMeals()
    }
    
    func fetchMeals() {
        NetworkManager.shared.fetchMeals { [weak self] meals in
            DispatchQueue.main.async {
                if let meals = meals {
                    self?.meals = meals
                } else {
                    self?.errormsg = "Failed to fetch meals."
                }
            }
        }
    }
}



//https://medium.com/@kevinbryanreligion/the-most-straight-forward-tutorial-on-how-to-use-healthkit-for-swiftui-a59bce6b2e96
//https://developer.apple.com/documentation/healthkit/hkhealthstore/1614152-requestauthorization
class HealthStoreViewModel: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var h_Steps: Double = 0.0
    @Published var health_CaloriesBurned: Double = 0.0
    @Published var SleepTime: Double = 0.0
    @Published var userWeightFromHealthKit: Double?


    func requestAuthorization() {
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.fetchTodayData()
            }
        }
    }


    func fetchTodayData() {
        getTodaysSteps()
        fetchTodayCaloriesBurned()
        fetchTodaySleepData()
        fetchLatestWeight()
    }
// Reference: https://stackoverflow.com/questions/36559581/healthkit-swift-getting-todays-steps
    private func getTodaysSteps() {

        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step Count type is no longer available in HealthKit")
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                self.h_Steps = steps
            }
        }

        healthStore.execute(query)
    }
//Reference: https://stackoverflow.com/questions/56311249/contents-of-data-returned-by-hkstatisticsquery

    private func fetchTodayCaloriesBurned() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            var calories = 0.0
            if let quantity = result?.sumQuantity() {
                calories = quantity.doubleValue(for: HKUnit.kilocalorie())
            }
            DispatchQueue.main.async {
                self.health_CaloriesBurned = calories
            }
        }

        healthStore.execute(query)
    }
//Reference: https://stackoverflow.com/questions/44849723/get-most-recent-data-point-from-hksamplequery

    private func fetchLatestWeight() {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            guard let results = results, let sample = results.first as? HKQuantitySample else {
                DispatchQueue.main.async {
                    self.userWeightFromHealthKit = nil
                }
                return
            }
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            DispatchQueue.main.async {
                self.userWeightFromHealthKit = weightInKilograms
            }
        }
        healthStore.execute(query)
    }
    //Reference: https://medium.com/@nathan.woolmore/retrieving-sleep-data-with-healthkit-in-swift-e81829f4a726

    private func fetchTodaySleepData() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)

        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            self.SleepTime = 0
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!, predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]) { _, result, error in
            var totalSleepTime: Double = 0

            if let result = result {
                for item in result {
                    if let sample = item as? HKCategorySample {
                        if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                            sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                            let sleepTime = sample.endDate.timeIntervalSince(sample.startDate)
                            totalSleepTime += sleepTime
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.SleepTime = totalSleepTime
            }
        }
        healthStore.execute(query)
    }
}



class MyActivityViewModel: ObservableObject {
    @Published var activitiesForToday: [Activity] = []
    @Published var totalStepsForToday: Int = 0
    @Published var totalCaloriesBurnedForToday: Double = 0.0
    @Published var sleepHoursToDisplay: Double = 0.0

    @Published var allActivities: [Activity] = [] {
        didSet {
            updateActivitiesForToday()
        }
    }

    @Published var proteinRecommendation: Double = 0.0
    @Published var waterRecommendation: Double = 0.0

    var healthStoreViewModel: HealthStoreViewModel?
    var userSettingsViewModel: UserSettingsViewModel?{
        //need to use this so that water and protien recommendations can be updated whenever a new value is entered.
        didSet {
            calculateRecommendations()
        }
    }

    init(healthStoreViewModel: HealthStoreViewModel!, userSettingsViewModel: UserSettingsViewModel!) {
        self.healthStoreViewModel = healthStoreViewModel
        self.userSettingsViewModel = userSettingsViewModel
        calculateRecommendations()
    }
    
    func updateActivitiesForToday() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        var todaysActivities: [Activity] = []
        var stepsTotal: Int = 0
        var caloriesTotal: Double = 0.0
    
    for activity in allActivities {
        if activity.date >= today && activity.date < tomorrow {
                todaysActivities.append(activity)
                stepsTotal += activity.steps
                caloriesTotal += activity.caloriesBurned
            }
        }
    activitiesForToday = todaysActivities
    totalStepsForToday = stepsTotal
    totalCaloriesBurnedForToday = caloriesTotal
        
    updateSleepHours()
    }

    func updateSleepHours() {
        // Initialize a variable to hold manual sleep hours
        var manualSleepHours: Double? = nil
        for activity in activitiesForToday {
            if let sleep = activity.sleepHours {
                manualSleepHours = sleep
                break
            }
        }
        if let sleepHours = manualSleepHours {
            sleepHoursToDisplay = sleepHours
        } 
        
        else if let totalSleepTime = healthStoreViewModel?.SleepTime {
            sleepHoursToDisplay = totalSleepTime / 3600
        } 
        
        else {
            sleepHoursToDisplay = 0
        }
    }


    func calculateRecommendations() {
        print("Entered Recommendations")
            guard let userWeight = userSettingsViewModel?.weight, userWeight > 0 else {
                proteinRecommendation = 0
                waterRecommendation = 0
                return
            }
            proteinRecommendation = userWeight * 1.2
            waterRecommendation = (userWeight * 35) / 1000
        }


    func stepsToDisplay() -> Int {
        if totalStepsForToday > 0 {
            return totalStepsForToday
        }
        else if let healthStoreVM = healthStoreViewModel {
            let healthKitSteps = healthStoreVM.h_Steps
            return Int(healthKitSteps)
        }
        else {
            return 0
        }
    }

    func caloriesToDisplay() -> Double {
        if totalCaloriesBurnedForToday > 0 {
            return totalCaloriesBurnedForToday
        }
        else if let healthStoreVM = healthStoreViewModel {
            let healthKitCaloriesBurned = healthStoreVM.health_CaloriesBurned
            return healthKitCaloriesBurned
        }
        else {
            return 0
        }
    }



    func sleepTimeToDisplay() -> String {
        let sleepHours = sleepHoursToDisplay
        let hours = Int(sleepHours)
        let minutes = Int((sleepHours - Double(hours)) * 60)
        return "\(hours)h \(minutes)m"
    }
}



class GoalsViewModel: ObservableObject {
    @Published var weeklyStepInput: String = ""
    @Published var goalCaloriesInput: String = ""
    @Published var totalStepsOverLastWeek: Double = 0.0
    @Published var totalCaloriesOverLastWeek: Double = 0.0
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    var userSettingsViewModel: UserSettingsViewModel?
    var allActivities: [Activity] = []

    func changeGoals() {
        guard let userSettingsVM = userSettingsViewModel else {
            errorMessage = "Invalid!"
            showError = true
            return
        }

        var valid = true
        
        if let stepGoal = Int(weeklyStepInput), stepGoal > 0 {
            userSettingsVM.weeklyStepGoal = stepGoal
        } else {
            errorMessage = "Invalid!."
            showError = true
            valid = false
        }

        // Attempt to convert weeklyCaloriesGoalInput to Double
        if let caloriesGoal = Double(goalCaloriesInput), caloriesGoal > 0 {
            userSettingsVM.weeklyCaloriesGoal = caloriesGoal
        } else {
            errorMessage = "Invalid for calories"
            showError = true
            valid = false
    }

        if valid {
            calculateTotals()
        }
    }

    func calculateTotals() {
        guard let userSettingsVM = userSettingsViewModel else {
            print("UserSettingsViewModel not set.")
            return
        }

        weeklyStepInput = "\(userSettingsVM.weeklyStepGoal)"
        goalCaloriesInput = "\(Int(userSettingsVM.weeklyCaloriesGoal))"

        let activities = activitiesOverLastWeek()

        var stepsTotal: Double = 0.0
        var caloriesTotal: Double = 0.0

        for activity in activities {
            stepsTotal += Double(activity.steps)
        }
        totalStepsOverLastWeek = stepsTotal

        for activity in activities {
            caloriesTotal += activity.caloriesIntake
        }
        totalCaloriesOverLastWeek = caloriesTotal
    }

    private func activitiesOverLastWeek() -> [Activity] {
        let today = Date()
        guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) else {
            print("Error")
            return []
        }

        var recentActivities: [Activity] = []

        for activity in allActivities {
            if activity.date >= oneWeekAgo && activity.date <= today {
                recentActivities.append(activity)
            }
        }

        return recentActivities
    }
}
