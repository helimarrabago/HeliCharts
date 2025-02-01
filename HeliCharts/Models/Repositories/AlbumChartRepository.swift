//
//  AlbumChartRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Combine
import Foundation

struct AlbumChartRepository: ChartRepository {
    typealias ChartType = AlbumChart
    static var allCharts = CurrentValueSubject<[AlbumChart], Never>([])
    static var totalUnitsCache: [YearKey<ChartEntryKind>: ChartEntryUnits<ChartEntryKind>] = [:]
    static var snapshotHistoryCache: [WeekKey<ChartEntryKind>: ChartSnapshotHistory] = [:]
    static var overallHistoryCache: [YearKey<ChartEntryKind>: ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearAndMetricKey: [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric: [AllTimeChartEntry]] = [:]
}
