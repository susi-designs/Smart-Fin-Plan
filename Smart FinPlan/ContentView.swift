// ContentView.swift
// Smart FinPlan
//
// Root view: a two-tab container that owns the shared FinancialPlannerViewModel
// and injects it as an environment object into both child tabs.

import SwiftUI

struct ContentView: View {
    /// Single ViewModel shared across the entire app via the environment.
    @StateObject private var viewModel = FinancialPlannerViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            PlanInputView()
                .tabItem {
                    Label("Plan", systemImage: "slider.horizontal.3")
                }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
