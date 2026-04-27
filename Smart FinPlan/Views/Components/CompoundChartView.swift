// CompoundChartView.swift
// Smart FinPlan
//
// Grouped bar chart visualising portfolio value at regular year intervals
// for all three investment strategies. Requires iOS 16+ (Swift Charts).

import SwiftUI
import Charts

struct CompoundChartView: View {
    @EnvironmentObject private var viewModel: FinancialPlannerViewModel

    /// All yearly samples from every portfolio, merged for the chart data source.
    private var chartData: [YearlyDataPoint] {
        viewModel.projections.flatMap { $0.yearlyDataPoints }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Section header
            VStack(alignment: .leading, spacing: 2) {
                Label("Compound Growth", systemImage: "chart.bar.xaxis")
                    .font(.headline)
                Text("Portfolio value over time with reinvested returns")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Grouped bar chart
            // Each x-axis tick = one year sample; three adjacent bars = three portfolios
            Chart(chartData) { point in
                BarMark(
                    x: .value("Year", "Yr \(point.year)"),
                    y: .value("Value", point.portfolioValue)
                )
                .foregroundStyle(by: .value("Portfolio", point.portfolioType.rawValue))
                .position(by: .value("Portfolio", point.portfolioType.rawValue))
                .cornerRadius(4)
            }
            // Map each portfolio name string to its design-system color
            .chartForegroundStyleScale([
                PortfolioType.conservative.rawValue: PortfolioType.conservative.color,
                PortfolioType.moderate.rawValue:     PortfolioType.moderate.color,
                PortfolioType.aggressive.rawValue:   PortfolioType.aggressive.color
            ])
            // Format y-axis labels as abbreviated currency ($50K, $1.2M, etc.)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(abbreviateCurrency(v))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartLegend(position: .bottom, alignment: .leading)
            .frame(height: 230)

            // Interest vs. principal breakdown for the moderate portfolio
            // (gives the user a sense of how much compounding contributes)
            if let moderate = viewModel.projections.first(where: { $0.type == .moderate }) {
                Divider()
                CompoundBreakdownRow(projection: moderate)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// Converts large dollar values to readable short-form labels for the y-axis.
    private func abbreviateCurrency(_ value: Double) -> String {
        switch value {
        case 1_000_000...: return String(format: "$%.1fM", value / 1_000_000)
        case 1_000...:     return String(format: "$%.0fK", value / 1_000)
        default:           return String(format: "$%.0f",  value)
        }
    }
}

// MARK: - Breakdown Row

/// Shows how much of the retirement goal is contributions vs. compound returns
/// for the moderate portfolio — a motivational callout.
private struct CompoundBreakdownRow: View {
    let projection: PortfolioProjection

    private var interestRatio: Double {
        guard projection.projectedValue > 0 else { return 0 }
        return projection.interestEarned / projection.projectedValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Moderate portfolio at retirement")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Stacked proportion bar
            GeometryReader { geo in
                HStack(spacing: 2) {
                    // Principal portion
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green.opacity(0.35))
                        .frame(width: geo.size.width * (1 - interestRatio))

                    // Returns portion
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.green)
                        .frame(width: max(geo.size.width * interestRatio, 4))
                }
            }
            .frame(height: 10)

            // Labels under the bar
            HStack {
                Circle().fill(Color.green.opacity(0.35)).frame(width: 8, height: 8)
                Text("Principal: " + projection.totalContributions
                    .formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.caption2).foregroundStyle(.secondary)

                Spacer()

                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("Returns: " + projection.interestEarned
                    .formatted(.currency(code: "USD").precision(.fractionLength(0))))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }
}
