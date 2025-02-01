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
    static var snapshotHistoryCache: [SnapshotHistoryKey<ChartEntryKind> : ChartSnapshotHistory] = [:]
    static var overallHistoryCache: [OverallHistoryKey<ChartEntryKind> : ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearEndChartKey : [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric : [AllTimeChartEntry]] = [:]
}
