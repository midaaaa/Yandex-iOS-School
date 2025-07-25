//
//  BalanceBarChart.swift
//  Finance Tamer
//
//  Created by Дмитрий Филимонов on 25.07.2025.
//

import SwiftUI
import Charts

struct BalanceBarChart: View {
    let entries: [BalanceHistoryEntry]
    @Binding var selectedBar: BalanceHistoryEntry?
    @Binding var popupX: CGFloat?
    @Binding var popupY: CGFloat?
    @Binding var chartWidth: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            Chart {
                ForEach(entries) { entry in
                    BarMark(
                        x: .value("Дата", entry.label),
                        y: .value("Баланс", abs(entry.balance))
                    )
                    .foregroundStyle(entry.balance < 0 ? Color.red : Color.green)
                    .cornerRadius(6)
                }
            }
            .chartXAxis {
                AxisMarks(values: xLabelValues) { value in
                    AxisValueLabel()
                }
            }
            .chartYAxis(.hidden)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(Color.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                if let (entry, _) = findEntry(at: location, proxy: proxy, geometry: geometry) {
                                    selectedBar = entry
                                    let global = geometry.frame(in: .local)
                                    popupX = location.x + global.origin.x
                                    popupY = location.y + global.origin.y - 10
                                    chartWidth = geo.size.width
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    selectedBar = nil
                                    popupX = nil
                                    popupY = nil
                                }
                            }
                        )
                }
            }
        }
    }
    
    private var xLabelValues: [String] {
        if entries.count > 4 {
            let second = entries[1].label
            let mid = entries[entries.count / 2].label
            let prelast = entries[entries.count - 2].label
            return [second, mid, prelast]
        } else {
            return entries.map { $0.label }
        }
    }
    
    private func findEntry(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> (BalanceHistoryEntry, Int)? {
        guard let plotFrameAnchor = proxy.plotFrame else { return nil }
        let plotFrame = geometry[plotFrameAnchor]
        let x = location.x - plotFrame.origin.x
        let index = Int((x / plotFrame.size.width) * CGFloat(entries.count))
        if entries.indices.contains(index) {
            return (entries[index], index)
        }
        return nil
    }
}

struct BalanceHistoryEntry: Identifiable, Hashable {
    let id: UUID = UUID()
    let label: String
    let balance: Decimal
}

#Preview {
    let serviceGroup = ServiceGroup()
    let viewModel = AccountViewModel(bankAccountService: serviceGroup.bankAccountService, transactionsService: serviceGroup.transactionService)
    AccountView(viewModel: viewModel)
        .environmentObject(serviceGroup)
        .task {
            await viewModel.loadBankAccount()
        }
}
