//
//  TrackChartRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Combine
import Foundation

struct TrackChartRepository: ChartRepository {
    typealias Chart = TrackChart
    static var allCharts = CurrentValueSubject<[TrackChart], Never>([])
    static var totalUnitsCache: [YearKey<ChartEntryKind>: ChartEntryUnits<ChartEntryKind>] = [:]
    static var snapshotHistoryCache: [WeekKey<ChartEntryKind>: ChartSnapshotHistory] = [:]
    static var overallHistoryCache: [YearKey<ChartEntryKind>: ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearAndMetricKey: [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric: [AllTimeChartEntry]] = [:]
}
