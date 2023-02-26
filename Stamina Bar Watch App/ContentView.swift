//
//  ContentView.swift
//  Stamina Bar Watch App
//
//  Created by Bryce Ellis on 11/18/22.
//

import SwiftUI
import HealthKit

// MARK: - Second Screen shows Weekly Heart Rate Statistics
struct DisplayHeartRateHistory: View {
    let heartRateQuantity = HKUnit(from: "count/min")
    private var healthStore = HKHealthStore()
    @State private var minHeartRate: Int = -1
    @State private var maxHeartRate: Int = 0
    @State private var currentHeartRate = 0
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 8) {
                    if currentHeartRate == 0 {
                        Text("Press Refresh...")
                    } else {
                        Text("Weekly Heart Rate")
                    }
                    Divider()
                    if minHeartRate == -1 && maxHeartRate == 0 {
                        HRHistoryCornerCase(title: "Current HR: ", value: "___", unit: "BPM")
                            .accentColor(.blue)
                            .multilineTextAlignment(.leading)
                        HRHistoryCornerCase(title: "Max HR: : ", value: "___", unit: "BPM")
                            .accentColor(.red)
                        HRHistoryCornerCase(title: "Min HR: ", value: "___", unit: "BPM")
                            .accentColor(.green)
                    } else {
                        
                        HeartRateHistoryView(title: "Current HR: ", value: currentHeartRate, unit: "BPM")
                            .accentColor(.blue)
                            .multilineTextAlignment(.leading)
                        HeartRateHistoryView(title: "Max HR: ", value: maxHeartRate, unit: "BPM")
                            .accentColor(.red)
                        HeartRateHistoryView(title: "Min HR: ",value: minHeartRate, unit: "BPM")
                            .accentColor(.green)
                    }
                    HStack {Button {
                        start()
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                        
                    }
                        .cornerRadius(5)
                        .tint(.mint)}
                }
                Spacer()
            }.padding()
        }
    }
    // MARK: - Set up HealthKit
    func start() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!         ]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            // 3
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        self.process(samples, type: quantityTypeIdentifier)
        }
        // 4
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        // 5
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            DispatchQueue.main.async {
                self.currentHeartRate = Int(lastHeartRate)
                if self.maxHeartRate < self.currentHeartRate {
                    self.maxHeartRate = self.currentHeartRate
                }
                if self.minHeartRate == -1 || self.minHeartRate > self.currentHeartRate {
                    self.minHeartRate = self.currentHeartRate
                }
            }
        }
    }
} // DisplayHeartRateHistory Struct

// MARK: - Third screen shows a smart message based on weekly HR Stats.
struct DisplayMessages: View {
    let heartRateQuantity = HKUnit(from: "count/min")
    private var healthStore = HKHealthStore()
    @State private var minHeartRate: Int = -1
    @State private var maxHeartRate: Int = 0
    @State private var currentHeartRate = 0
    @State private var showButton: Bool = true
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 8) {
                    if currentHeartRate == 0 {
                        Text("Press Refresh...")
                    } else {
                        Text("Summary")
                    }
                    Divider()
                    HStack {
                        Button {
                        start()
                        
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                        .cornerRadius(5)
                        .tint(.mint)
                    }
                }
                Spacer()
            }.padding()
        }
    }
    // MARK: - Set up HealthKit
    func start() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            // 3
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        self.process(samples, type: quantityTypeIdentifier)
        }
        // 4
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        // 5
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            DispatchQueue.main.async {
                self.currentHeartRate = Int(lastHeartRate)
                if self.maxHeartRate < self.currentHeartRate {
                    self.maxHeartRate = self.currentHeartRate
                }
                if self.minHeartRate == -1 || self.minHeartRate > self.currentHeartRate {
                    self.minHeartRate = self.currentHeartRate
                }
            }
        }
    }
} // DisplayMessages Struct

struct DisplayStaminaBar: View {
    // MARK: - Wellness/Heart Data fields to manipulate
    let heartRateQuantity = HKUnit(from: "count/min")
    private var healthStore = HKHealthStore()
    @State private var minHeartRate: Int = -1
    @State private var maxHeartRate: Int = 0
    @State private var currentHeartRate = 0
    // MARK: - Stamina Bar simplifies Heart Rate Zones
    var body: some View {
        VStack (alignment: .trailing, spacing: 10) {
            if currentHeartRate == 0 {
                Image("Refresh")
            }
            // Green
            else if currentHeartRate < 70 {Image("100")}
            else if currentHeartRate < 75 {Image("95")}
            else if currentHeartRate < 80 {Image("90")}
            else if currentHeartRate < 100 {Image("85")}
            // Yellow
            else if currentHeartRate < 105 {Image("80")}
            else if currentHeartRate < 115 {Image("75")}
            else if currentHeartRate < 135 {Image("70")}
            else if currentHeartRate < 145 {Image("65")}
            else if currentHeartRate < 155 {Image("60")}
            else if currentHeartRate < 160 {Image("55")}
            // Orange
            else if currentHeartRate < 165 {Image("50")}
            else if currentHeartRate < 169 {Image("45")}
            else if currentHeartRate < 177 {Image("40")}

            // Red
            else if currentHeartRate < 180 {Image("35")}
            else if currentHeartRate < 185 {Image("30")}
            //25
            else {Image("20")}
    // MARK: - UI Elements Under Stamina Bar
            HStack {Button {
                start()
                
            } label: {
                Image(systemName: "arrow.clockwise")
                
            }   .frame(width: 80, height: 60)
                .cornerRadius(5)
                .tint(.mint)
                    Text("\(currentHeartRate) BPM")
                if currentHeartRate == 0 {Image(systemName: "suit.heart.fill")} else {Image(systemName: "suit.heart.fill")
                    .foregroundColor(.red)}}
        }
        .padding()
    }
    
    // MARK: - Set up HealthKit
    func start() {
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            // 3
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
        self.process(samples, type: quantityTypeIdentifier)
        }
        // 4
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        // 5
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            DispatchQueue.main.async {
                self.currentHeartRate = Int(lastHeartRate)
                if self.maxHeartRate < self.currentHeartRate {
                    self.maxHeartRate = self.currentHeartRate
                }
                if self.minHeartRate == -1 || self.minHeartRate > self.currentHeartRate {
                    self.minHeartRate = self.currentHeartRate
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            DisplayStaminaBar()
            DisplayHeartRateHistory()
            DisplayMessages()
        }
        .tabViewStyle(.page)
        .edgesIgnoringSafeArea(.vertical)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
