//
//  CacheKeys.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/3/25.
//

import Foundation

struct MetricKey: Hashable {
    let metric: ChartMetric
}

struct WeekKey<ChartEntryType: ChartEntry>: Hashable {
    let entry: ChartEntryType
    let week: WeekRange
}

struct YearKey<ChartEntryType: ChartEntry>: Hashable {
    let entry: ChartEntryType
    let year: Int?
}

struct YearAndMetricKey: Hashable {
    let year: Int
    let metric: ChartMetric
}

struct MetricAndLimitKey: Hashable {
    let metric: ChartMetric
    let artistLimit: Int?
}
