// FinancialPlannerViewModel.swift
// Smart FinPlan
//
// Single source of truth for all financial inputs and projections.
// Persists inputs to UserDefaults and recalculates automatically via Combine.

import Foundation
import Combine

class FinancialPlannerViewModel: ObservableObject {

    // MARK: - Inputs (two-way bound from PlanInputView)
    @Published var currentAge: Int        = 30
    @Published var retirementAge: Int     = 65
    @Published var goalAmount: Double     = 1_000_000
    @Published var currentSavings: Double = 0

    // MARK: - Outputs (consumed by HomeView)
    @Published var projections: [PortfolioProjection] = []

    // MARK: - Derived helpers
    var yearsToRetirement: Int  { max(retirementAge - currentAge, 0) }
    var monthsToRetirement: Int { yearsToRetirement * 12 }
    var isValidInput: Bool      { retirementAge > currentAge && goalAmount > 0 }

    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard

    // MARK: - Init
    init() {
        loadSavedValues()

        // Persist and recalculate whenever any input changes.
        // dropFirst() skips the initial publisher fire that happens on subscription.
        Publishers.CombineLatest4($currentAge, $retirementAge, $goalAmount, $currentSavings)
            .dropFirst()
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.persistValues()
                self?.calculateProjections()
            }
            .store(in: &cancellables)

        calculateProjections()
    }

    // MARK: - Persistence

    private func loadSavedValues() {
        currentAge     = defaults.object(forKey: "fp_currentAge")     as? Int    ?? 30
        retirementAge  = defaults.object(forKey: "fp_retirementAge")  as? Int    ?? 65
        goalAmount     = defaults.object(forKey: "fp_goalAmount")      as? Double ?? 1_000_000
        currentSavings = defaults.object(forKey: "fp_currentSavings")  as? Double ?? 0
    }

    private func persistValues() {
        defaults.set(currentAge,     forKey: "fp_currentAge")
        defaults.set(retirementAge,  forKey: "fp_retirementAge")
        defaults.set(goalAmount,     forKey: "fp_goalAmount")
        defaults.set(currentSavings, forKey: "fp_currentSavings")
    }

    // MARK: - Projection Calculation

    func calculateProjections() {
        guard isValidInput else { projections = []; return }
        projections = PortfolioType.allCases.map { buildProjection(for: $0) }
    }

    private func buildProjection(for type: PortfolioType) -> PortfolioProjection {
        let r = type.monthlyReturnRate
        let n = monthsToRetirement

        // Compound the existing savings forward to retirement date.
        // FV = PV × (1 + r)^n
        let fvCurrentSavings = currentSavings * pow(1 + r, Double(n))

        // Monthly contributions only need to cover the shortfall after existing savings grow.
        let remainingGoal = max(goalAmount - fvCurrentSavings, 0)

        // PMT (Future Value annuity formula):
        //   FV = PMT × ((1 + r)^n − 1) / r
        //   → PMT = FV × r / ((1 + r)^n − 1)
        let pmt = calculatePMT(futureValue: remainingGoal, monthlyRate: r, months: n)

        let totalContributions = (pmt * Double(n)) + currentSavings
        let interestEarned     = max(goalAmount - totalContributions, 0)

        return PortfolioProjection(
            type: type,
            monthlyContribution: max(pmt, 0),
            projectedValue: goalAmount,
            totalContributions: totalContributions,
            interestEarned: interestEarned,
            yearlyDataPoints: buildYearlyDataPoints(type: type, pmt: pmt, monthlyRate: r)
        )
    }

    /// Standard PMT formula for a future-value annuity (ordinary annuity, end-of-period payments).
    private func calculatePMT(futureValue: Double, monthlyRate: Double, months: Int) -> Double {
        guard months > 0       else { return 0 }
        guard monthlyRate > 0  else { return futureValue / Double(months) }
        let factor = pow(1 + monthlyRate, Double(months))
        return futureValue * monthlyRate / (factor - 1)
    }

    /// Samples portfolio value at regular intervals for the compound-interest chart.
    /// Uses 5-year steps for long timelines (> 10 yrs) and 1-year steps for short ones.
    private func buildYearlyDataPoints(
        type: PortfolioType,
        pmt: Double,
        monthlyRate: Double
    ) -> [YearlyDataPoint] {
        let totalYears = yearsToRetirement
        let step = totalYears > 10 ? 5 : 1
        var points: [YearlyDataPoint] = []

        for year in stride(from: step, through: totalYears, by: step) {
            let n = year * 12  // months elapsed at this sample

            // FV of all monthly contributions up to this point:
            // FV_annuity = PMT × ((1 + r)^n − 1) / r
            let fvContributions: Double
            if monthlyRate > 0 {
                fvContributions = pmt * (pow(1 + monthlyRate, Double(n)) - 1) / monthlyRate
            } else {
                fvContributions = pmt * Double(n)
            }

            // FV of the initial lump-sum savings at this point
            let fvSavings = currentSavings * pow(1 + monthlyRate, Double(n))

            points.append(YearlyDataPoint(
                year: year,
                portfolioValue: fvContributions + fvSavings,
                portfolioType: type
            ))
        }
        return points
    }
}
