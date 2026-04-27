// Smart_FinPlanApp.swift
// Smart FinPlan
//
// App entry point. Core Data is retained in Persistence.swift for future use
// but the app now uses UserDefaults for lightweight plan persistence.

import SwiftUI

@main
struct Smart_FinPlanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
