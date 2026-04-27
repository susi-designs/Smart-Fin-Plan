// PortfolioCardView.swift
// Smart FinPlan
//
// A single row card showing the required monthly contribution
// and key stats for one portfolio strategy.

import SwiftUI

struct PortfolioCardView: View {
    let projection: PortfolioProjection

    var body: some View {
        HStack(spacing: 14) {

            // Colored icon badge
            ZStack {
                Circle()
                    .fill(projection.type.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: projection.type.sfSymbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(projection.type.color)
            }

            // Portfolio name, tagline, and expected return
            VStack(alignment: .leading, spacing: 3) {
                Text(projection.type.rawValue)
                    .font(.headline)

                Text(projection.type.tagline)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Badge showing annual return rate
                Text("\(Int(projection.type.annualReturnRate * 100))% avg / yr")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(projection.type.color.opacity(0.12))
                    .foregroundStyle(projection.type.color)
                    .clipShape(Capsule())
            }

            Spacer()

            // Required monthly deposit (the key output)
            VStack(alignment: .trailing, spacing: 2) {
                Text(projection.monthlyContribution,
                     format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(projection.type.color)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("/ month")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
