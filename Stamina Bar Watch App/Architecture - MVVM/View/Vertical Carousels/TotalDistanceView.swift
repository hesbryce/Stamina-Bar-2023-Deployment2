//
//  TotalDistanceView.swift
//  Stamina Bar Watch App
//
//  Created by Bryce Ellis on 1/8/24.
//

import Foundation

import SwiftUI
import HealthKit

struct TotalDistanceView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.scenePhase) private var scenePhase
    
    var distanceTraveled: Double {
        let stepsPerMile = 2000.0
        return Double(workoutManager.dailyStepCount) / stepsPerMile
    }
    
    let staminaBarView = StaminaBarView()
    
    var body: some View {
        TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
            
            VStack (alignment: .trailing) {
                ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0)
                    .foregroundStyle(.white)
                    .font(.system(.title2, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scenePadding()
                (staminaBarView.stressFunction(heart_rate: workoutManager.heartRate) as AnyView)
                
                HStack {
                    Text(String(format: "%.2f Miles", distanceTraveled))
                        .font(.system(.body, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                    
                    Image(systemName: "shoeprints.fill")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct TotalDistanceView_Previews: PreviewProvider {
    static var previews: some View {
        TotalDistanceView().environmentObject(WorkoutManager())
    }
}

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
