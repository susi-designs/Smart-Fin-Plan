// PortfolioModels.swift
// Smart FinPlan
//
// Defines the core data types: portfolio risk profiles, chart data points,
// and the full projection result for one portfolio strategy.

import SwiftUI

// MARK: - Portfolio Type

/// The three investment risk/return profiles the planner supports.
enum PortfolioType: String, CaseIterable, Identifiable {
    case conservative = "Conservative"
    case moderate     = "Moderate"
    case aggressive   = "Aggressive"

    var id: String { rawValue }

    /// Long-run average annual return for each style (based on historical data).
    var annualReturnRate: Double {
        switch self {
        case .conservative: return 0.05   // 5%  — bonds, CDs, stable-value funds
        case .moderate:     return 0.08   // 8%  — 60/40 stock-bond blend
        case .aggressive:   return 0.12   // 12% — growth equities, total-market index
        }
    }

    /// Monthly rate derived from the annual rate (compounded monthly).
    var monthlyReturnRate: Double { annualReturnRate / 12.0 }

    var color: Color {
        switch self {
        case .conservative: return .blue
        case .moderate:     return .green
        case .aggressive:   return .orange
        }
    }

    /// SF Symbol that visually represents this risk level.
    var sfSymbol: String {
        switch self {
        case .conservative: return "shield.fill"
        case .moderate:     return "chart.bar.fill"
        case .aggressive:   return "flame.fill"
        }
    }

    var tagline: String {
        switch self {
        case .conservative: return "Lower risk · Steady growth"
        case .moderate:     return "Balanced risk & reward"
        case .aggressive:   return "Higher risk · Max growth"
        }
    }
}

// MARK: - Chart Data Point

/// One data sample used by the compound-interest bar chart.
struct YearlyDataPoint: Identifiable {
    let id = UUID()
    let year: Int                    // years elapsed from today
    let portfolioValue: Double       // total portfolio value at that point
    let portfolioType: PortfolioType
}

// MARK: - Portfolio Projection

/// Complete retirement projection for one portfolio strategy.
struct PortfolioProjection: Identifiable {
    let id = UUID()
    let type: PortfolioType
    let monthlyContribution: Double  // required monthly deposit to hit the goal
    let projectedValue: Double       // total at retirement (equals the user's goal)
    let totalContributions: Double   // sum of all deposits (principal only, no returns)
    let interestEarned: Double       // wealth generated purely by compounding
    let yearlyDataPoints: [YearlyDataPoint]
}
