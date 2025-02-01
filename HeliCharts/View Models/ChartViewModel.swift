//
//  ChartViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

protocol ChartsViewModelProtocol: ObservableObject {
    init()
    func generateDetailedChart(for topChart: TopChartEntryUIModel) async -> ChartUIModel
}

final class ChartViewModel: ChartsViewModelProtocol {
    func generateDetailedChart(for topChart: TopChartEntryUIModel) async -> ChartUIModel {
        return ChartUIModel(topEntry: topChart)
    }
}
