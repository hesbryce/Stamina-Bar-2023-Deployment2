//
//  SettingsView.swift
//  Stamina Bar Watch App
//
//  Created by Bryce Ellis on 3/27/24.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    // Example settings
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    
    // Accessing app version and build number
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    
    var body: some View {
        ScrollView {
            Section {
                ScanQRView()
                Divider()
                AppVersionView()
            }
        }
    }
}


struct AppVersionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Accessing app version and build number
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    
    
    var body: some View {
        Section {
            VStack(alignment: .center, spacing: 10) {
                Text("App Version")
                    .font(.headline)
                Text("v\(appVersion)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            
        }
    }
    
}

struct ScanQRView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            Section {
                VStack(alignment: .center, spacing: 10) {
                    Image("QR-Code") // Make sure this is the name of your QR code image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Scan for FAQ's")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
