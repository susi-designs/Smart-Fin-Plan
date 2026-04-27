// HomeView.swift
// Smart FinPlan
//
// Dashboard tab: shows the retirement summary, three portfolio cards,
// and the compound interest bar chart. All data comes from the shared ViewModel.

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: FinancialPlannerViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isValidInput && !viewModel.projections.isEmpty {
                    dashboardContent
                } else {
                    emptyState
                }
            }
            .navigationTitle("Smart FinPlan")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Retirement snapshot card
                SummaryHeaderView()

                // Monthly savings plan cards (one per portfolio type)
                VStack(alignment: .leading, spacing: 12) {
                    Label("Monthly Savings Plan", systemImage: "calendar.badge.plus")
                        .font(.headline)
                        .padding(.horizontal, 4)

                    ForEach(viewModel.projections) { projection in
                        PortfolioCardView(projection: projection)
                    }
                }

                // Compound interest bar chart
                CompoundChartView()

                // Contextual footnote
                Text("Projections use average historical returns and assume consistent monthly contributions. Past performance is not a guarantee of future results.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Set Your Retirement Plan", systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            Text("Tap **Plan** below to enter your age,\nretirement target, and savings goal.")
        }
    }
}
