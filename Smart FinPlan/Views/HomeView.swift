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
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), .blue.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
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

                    HStack(spacing: 12) {
                        ForEach(viewModel.projections) { projection in
                            PortfolioCardCompactView(projection: projection)
                        }
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

// MARK: - Compact Portfolio Card (horizontal layout)

private struct PortfolioCardCompactView: View {
    let projection: PortfolioProjection

    var body: some View {
        VStack(spacing: 10) {
            // Icon badge
            ZStack {
                Circle()
                    .fill(projection.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: projection.type.sfSymbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(projection.type.color)
            }

            // Portfolio name
            Text(projection.type.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Rate badge
            Text("\(Int(projection.type.annualReturnRate * 100))%/yr")
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(projection.type.color.opacity(0.12))
                .foregroundStyle(projection.type.color)
                .clipShape(Capsule())

            // Monthly amount
            Text(projection.monthlyContribution,
                 format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(projection.type.color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text("/ month")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
