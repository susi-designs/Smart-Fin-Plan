//
//  Smart_FinPlanApp.swift
//  Smart FinPlan
//
//  Created by Rama Lakshmi on 4/26/26.
//

import SwiftUI
import CoreData

@main
struct Smart_FinPlanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
