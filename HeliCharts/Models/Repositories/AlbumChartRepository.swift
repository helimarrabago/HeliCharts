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
    static var appearancesSoFarCache: [WeekKey<ChartEntryType>: [ChartEntryType]] = [:]
    static var totalUnitsCache: [YearKey<ChartEntryType>: ChartEntryUnits<ChartEntryType>] = [:]
    static var snapshotHistoryCache: [WeekKey<ChartEntryType>: ChartEntrySnapshotHistory] = [:]
    static var overallHistoryCache: [YearKey<ChartEntryType>: ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearAndMetricKey: [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric: [AllTimeChartEntry]] = [:]
    static var mostWeeklyUnitsCache: [MetricKey: [MostWeeklyUnits]] = [:]
}
