// PlanInputView.swift
// Smart FinPlan
//
// Plan tab: a grouped Form where the user edits all financial inputs.
// Changes flow to the ViewModel instantly and trigger projection recalculation.

import SwiftUI

struct PlanInputView: View {
    @EnvironmentObject private var viewModel: FinancialPlannerViewModel

    /// Tracks which text field owns keyboard focus so the Done toolbar button works.
    @FocusState private var focusedField: Field?

    private enum Field { case goal, savings }

    var body: some View {
        NavigationStack {
            Form {
                agesSection
                financialGoalsSection
                rateReferenceSection
            }
            .navigationTitle("Plan Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // "Done" button dismisses the keyboard when a text field is focused
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
        }
    }

    // MARK: - Ages Section

    private var agesSection: some View {
        Section {
            // Stepper: current age
            Stepper(value: $viewModel.currentAge, in: 18...79) {
                Label {
                    HStack {
                        Text("Current Age")
                        Spacer()
                        Text("\(viewModel.currentAge)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                } icon: {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.blue)
                }
            }

            // Stepper: retirement age (floor is always currentAge + 1)
            Stepper(value: $viewModel.retirementAge, in: (viewModel.currentAge + 1)...100) {
                Label {
                    HStack {
                        Text("Retirement Age")
                        Spacer()
                        Text("\(viewModel.retirementAge)")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
        } header: {
            Text("Ages")
        } footer: {
            if !viewModel.isValidInput {
                Label("Retirement age must be greater than current age.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            } else {
                Text("\(viewModel.yearsToRetirement) years · \(viewModel.monthsToRetirement) months until retirement")
            }
        }
    }

    // MARK: - Financial Goals Section

    private var financialGoalsSection: some View {
        Section {
            // Retirement goal amount — currency text field
            HStack {
                Label("Retirement Goal", systemImage: "target")
                Spacer()
                TextField(
                    "Amount",
                    value: $viewModel.goalAmount,
                    format: .currency(code: "USD").precision(.fractionLength(0))
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .goal)
                .foregroundStyle(.primary)
            }

            // Current savings — compounds at each portfolio's rate
            HStack {
                Label("Current Savings", systemImage: "banknote.fill")
                Spacer()
                TextField(
                    "Savings",
                    value: $viewModel.currentSavings,
                    format: .currency(code: "USD").precision(.fractionLength(0))
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($focusedField, equals: .savings)
                .foregroundStyle(.primary)
            }
        } header: {
            Text("Financial Goals")
        } footer: {
            Text("Existing savings will compound at each portfolio's return rate and reduce your required monthly contribution.")
        }
    }

    // MARK: - Rate Reference Section

    /// Read-only reference rows showing the assumed annual return for each portfolio.
    private var rateReferenceSection: some View {
        Section("Expected Annual Returns") {
            ForEach(PortfolioType.allCases) { type in
                HStack(spacing: 12) {
                    Image(systemName: type.sfSymbol)
                        .foregroundStyle(type.color)
                        .frame(width: 24, alignment: .center)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.rawValue)
                            .font(.subheadline)
                        Text(type.tagline)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(Int(type.annualReturnRate * 100))%")
                        .font(.headline)
                        .foregroundStyle(type.color)
                }
                .padding(.vertical, 2)
            }
        }
    }
}
