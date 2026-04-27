// SummaryHeaderView.swift
// Smart FinPlan
//
// Dashboard card showing the user's goal, years to retirement, and age journey.

import SwiftUI

struct SummaryHeaderView: View {
    @EnvironmentObject private var viewModel: FinancialPlannerViewModel

    var body: some View {
        VStack(spacing: 0) {

            // Top row: retirement goal | years to retire
            HStack(spacing: 0) {
                MetricCell(
                    icon: "target",
                    label: "Retirement Goal",
                    value: viewModel.goalAmount
                        .formatted(.currency(code: "USD").precision(.fractionLength(0)))
                )

                Divider()

                MetricCell(
                    icon: "hourglass.bottomhalf.filled",
                    label: "Years to Retire",
                    value: "\(viewModel.yearsToRetirement) yrs"
                )
            }
            .frame(height: 80)

            Divider()

            // Bottom row: age journey  (person → retirement star)
            HStack(spacing: 6) {
                Image(systemName: "person.fill")
                    .foregroundStyle(.secondary)
                Text("Age \(viewModel.currentAge)")
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)

                Spacer()

                Text("Retire at \(viewModel.retirementAge)")
                    .foregroundStyle(.secondary)
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.subheadline)
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// A single metric tile used inside SummaryHeaderView.
private struct MetricCell: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
