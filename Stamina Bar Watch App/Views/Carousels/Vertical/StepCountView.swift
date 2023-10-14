//
//  StepCountView.swift
//  Stamina Bar Watch App
//
//  Created by Bryce Ellis on 10/8/23.
//  refractor unused data

import Foundation
import SwiftUI
import HealthKit
    // CHANGE
struct StepCountView: View {
    // MARK: Data Fields
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.scenePhase) private var scenePhase
    let legacyHealthStore = HKHealthStore()
    @State private var legacyRestingEnergy: Double = 0.0
    @State private var legacyActiveEnergy: Double = 0.0
    @State private var previousVO2Max: Double? = nil
    @State private var getStepCount: Int = 0
    @State var heartRateVariability: Double? = nil
    @State private var isLoaded: Bool = false
    @State private var vo2Max: Double = 0.0
    @State private var userAge: Int = 0
    @State private var timer: Timer?

    let staminaBarView = StaminaBarView()
    
    var body: some View {
            // MARK: Stamina Bar selected
            if workoutManager.selectedWorkout == .other {
                TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
                        // Stamina Bar and Heart Rate
                        VStack (alignment: .trailing) {
                            // Timer
                            ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0)
                                .foregroundStyle(.white)
                                .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                //.ignoresSafeArea(edges: .bottom)
                                .scenePadding()
                                // Currently reads HR
                                // TODO: Add HRV into function
                            (staminaBarView.stressFunction(heart_rate: workoutManager.heartRate) as AnyView)
                            
                            // TODO: Modify these for your vertical scrolls
                            HStack {
                                Text("\(getStepCount) Steps")
                                .font(.system(.body, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                                .fontWeight(.bold)


                                Image(systemName: "figure.walk")
                                    .foregroundColor(.blue)
                            }
                        } .onAppear {
                            fetchStepCount()
                            endProlongedWorkout()
                        }
                    
                }
            } // end stamina bar selected
        
        
        else if workoutManager.selectedWorkout == .yoga ||  workoutManager.selectedWorkout == .traditionalStrengthTraining || workoutManager.selectedWorkout == .highIntensityIntervalTraining {
            TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
                    // Stamina Bar and Heart Rate
                    VStack (alignment: .trailing) {
                        // Timer
                        ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0)
                            .foregroundStyle(.white)
                            .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            //.ignoresSafeArea(edges: .bottom)
                            .scenePadding()
                        (staminaBarView.stressFunction(heart_rate: workoutManager.heartRate) as AnyView)
                        
                        // CHANGE HERE
                        HStack {
                            Text("\(getStepCount) Steps")
                            .font(.system(.body, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                            .fontWeight(.bold)


                            Image(systemName: "figure.walk")
                                .foregroundColor(.blue)
                        }
                    } .onAppear {
                        fetchStepCount()
                    }
            }
        } // end
        
        
        else {
            TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(),
                                                 isPaused: workoutManager.session?.state == .paused)) { context in
                VStack(alignment: .leading) {
                    // Timer
                    ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0)
                        .foregroundStyle(.white)
                        .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .ignoresSafeArea(edges: .bottom)
                        .scenePadding()

                    // Stamina Bar
                    (staminaBarView.stressFunction(heart_rate: workoutManager.heartRate) as AnyView)
                    HStack {
                        Spacer()
                        // CHANGE HERE
                        Text("\(getStepCount) Steps")
                        .font(.system(.body, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                        .fontWeight(.bold)


                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                    }
                    
                    
                    // AXE
                    // Distance and Proper formatting of it.
                    if workoutManager.distance < 0.5 {
                        Text(Measurement(value: workoutManager.distance, unit: UnitLength.miles).formatted(.measurement(width: .abbreviated, usage: .road, numberFormatStyle: .number.precision(.fractionLength(0)))))
                            .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .ignoresSafeArea(edges: .bottom)
                            .scenePadding()
                    } else {
                        Text(Measurement(value: workoutManager.distance, unit: UnitLength.miles).formatted(.measurement(width: .abbreviated, usage: .road, numberFormatStyle: .number.precision(.fractionLength(2)))))
                            .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .ignoresSafeArea(edges: .bottom)
                            .scenePadding()
                        }
                } .onAppear {
                    fetchStepCount()
                }

                }
            }
        
        
                
    }
    
    func endProlongedWorkout() {
        Timer.scheduledTimer(withTimeInterval: 30 * 61, repeats: false) { timer in
            // Workout has ended, perform the end workout logic here
            workoutManager.endWorkout()
        }.tolerance = 0.5
    }
    
    // MARK: Functions
    var getTotalEnergy: String {
        let total = legacyActiveEnergy + legacyRestingEnergy
        // Formats 999 to 1.0K, 2.7K, 12.2K etc
        if total >= 1000 {
            let remainder = total.truncatingRemainder(dividingBy: 1000.0)
            let thousands = Int(total / 1000.0) // get the number of thousands
            if remainder == 0 {
                return "\(thousands)K"
            } else {
                return "\(thousands).\(Int(remainder / 100.0))K"
            }
        } else {
            return String(format: "%.0f", total)
        }
    }

    // Execute query to read HRV
    func fetchHeartRateVariability() {
            // check if HealthKit is available on this device
            guard HKHealthStore.isHealthDataAvailable() else {
                print("HealthKit is not available on this device")
                return
            }
                    // read the user's latest heart rate variability data
                    let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
                    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                    let query = HKSampleQuery(sampleType: heartRateVariabilityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                        guard let samples = samples as? [HKQuantitySample], let firstSample = samples.first else {
                            print("No heart rate variability samples available")
                            return
                        }
                        let heartRateVariability = firstSample.quantity.doubleValue(for: .init(from: "ms"))
                        DispatchQueue.main.async {
                            self.heartRateVariability = heartRateVariability
                        }
                    }
                    legacyHealthStore.execute(query)
        }
    
    // Execute query to retrieve basal energy
    func startLegacyRestingEnergyQuery() {
        let restingEnergyType = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let query = HKStatisticsQuery(quantityType: restingEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to retrieve resting energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.legacyRestingEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
        }
        legacyHealthStore.execute(query)
    }
    
    // Execute query to retrieve active energy
    private func startLegacyActiveEnergyQuery() {
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to retrieve active energy data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.legacyActiveEnergy = sum.doubleValue(for: HKUnit.kilocalorie())
        }
        legacyHealthStore.execute(query)
    }
    
    func loadVO2Max() {
        let vo2MaxType = HKObjectType.quantityType(forIdentifier: .vo2Max)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: vo2MaxType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            if let vo2Max = results?.first as? HKQuantitySample {
                self.previousVO2Max = self.vo2Max
                self.vo2Max = vo2Max.quantity.doubleValue(for: HKUnit(from: "ml/kg*min"))
                self.isLoaded = true
            } else {
                print("Failed to retrieve VO2 Max data: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        legacyHealthStore.execute(query)
    }

    
    // Get's HRV every 50 min
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3000, repeats: true) { _ in
            fetchHeartRateVariability()
            //HapticManager.successHaptic()
            timer?.invalidate()
            timer = nil
            startTimer() // Start a new timer after each trigger
            
        }
    }

    // Get's current step count
    func fetchStepCount() {
           // Check if HealthKit is available on the device
           guard HKHealthStore.isHealthDataAvailable() else {
               print("HealthKit is not available on this device.")
               return
           }

           // Define the HealthKit type you want to read (step count)
           let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!

           // Set the time range for which you want to fetch step count (today)
           let calendar = Calendar.current
           let now = Date()
           let startOfDay = calendar.startOfDay(for: now)
           let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

           // Build the query
           let query = HKStatisticsQuery(quantityType: stepCountType,
                                         quantitySamplePredicate: predicate,
                                         options: .cumulativeSum) { query, result, error in
               guard let result = result, let sum = result.sumQuantity() else {
                   print("Error fetching step count. Error: \(error?.localizedDescription ?? "Unknown error")")
                   return
               }

               // Update UI on the main thread
               DispatchQueue.main.async {
                   self.getStepCount = Int(sum.doubleValue(for: .count()))
               }
           }

           // Execute the query
           HKHealthStore().execute(query)
       }



    
} // End SwiftUI View
    
    // Default code
    // Change
    struct StepCountView_Previews: PreviewProvider {
        static var previews: some View {
            // CHANGE
            StepCountView().environmentObject(WorkoutManager())
        }
    }
    
    // Workout builder helper
    private struct MetricsTimelineSchedule: TimelineSchedule {
        var startDate: Date
        var isPaused: Bool
        
        init(from startDate: Date, isPaused: Bool) {
            self.startDate = startDate
            self.isPaused = isPaused
        }
        
        func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
            var baseSchedule = PeriodicTimelineSchedule(from: self.startDate,
                                                        by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
                .entries(from: startDate, mode: mode)
            
            return AnyIterator<Date> {
                guard !isPaused else { return nil }
                return baseSchedule.next()
            }
        }
        
    }
    
