//
//  Stamina_BarApp.swift
//  Stamina Bar Watch App
//
//  Created by Bryce Ellis on 11/18/22.

import SwiftUI

@main
struct Stamina_Bar_Watch_AppApp: App {
    @StateObject private var workoutManager = WorkoutManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
