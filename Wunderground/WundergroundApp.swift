//
//  WundergroundApp.swift
//  Wunderground
//
//  Created by Olaf on 14.06.25.
//

import SwiftUI

@main
struct WundergroundApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            SettingsView()
        }
    }
}
