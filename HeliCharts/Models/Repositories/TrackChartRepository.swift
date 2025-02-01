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
    static var snapshotHistoryCache: [SnapshotHistoryKey<ChartEntryKind> : ChartSnapshotHistory] = [:]
    static var overallHistoryCache: [OverallHistoryKey<ChartEntryKind> : ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearEndChartKey : [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric : [AllTimeChartEntry]] = [:]
}
