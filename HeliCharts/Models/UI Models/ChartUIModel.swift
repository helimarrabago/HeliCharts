//
//  ChartUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

struct ChartUIModel {
    let id: String
    let week: String
    let entries: [ChartEntryUIModel]
    let type: ChartType
    let chart: any Chart

    init(id: String, week: String, entries: [ChartEntryUIModel], type: ChartType, chart: some Chart) {
        self.id = id
        self.week = week
        self.entries = entries
        self.type = type
        self.chart = chart
    }

    init(topEntry: TopChartEntryUIModel) {
        self.id = topEntry.id
        self.week = topEntry.week
        self.entries = topEntry.chart.entries.map { ChartEntryUIModel(entry: $0) }
        self.type = topEntry.type
        self.chart = topEntry.chart
    }
}
