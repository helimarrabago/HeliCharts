//
//  ArtistChartRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Combine
import Foundation

struct ArtistChartRepository: ChartRepository {
    typealias ChartType = ArtistChart
    static var allCharts = CurrentValueSubject<[ArtistChart], Never>([])
    static var appearancesSoFarCache: [WeekKey<ChartEntryType>: [ChartEntryType]] = [:]
    static var totalUnitsCache: [YearKey<ChartEntryType>: ChartEntryUnits<ChartEntryType>] = [:]
    static var snapshotHistoryCache: [WeekKey<ChartEntryType>: ChartEntrySnapshotHistory] = [:]
    static var overallHistoryCache: [YearKey<ChartEntryType>: ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearAndMetricKey: [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [MetricAndLimitKey: [AllTimeChartEntry]] = [:]
    static var mostWeeklyUnitsCache: [MetricKey: [WeeklyRecord]] = [:]
    static var biggestDebutsCache: [MetricKey: [WeeklyRecord]] = [:]
    static var biggestPeaksCache: [MetricKey: [WeeklyRecord]] = [:]
    static var chartRunCache: [YearAndMilestoneValueKey<ChartEntryType>: [ChartRunSnapshot]] = [:]
    static var fastestMilestoneUnitsCache: [MetricAndMilestoneValueKey: [FastestRecord]] = [:]
}
