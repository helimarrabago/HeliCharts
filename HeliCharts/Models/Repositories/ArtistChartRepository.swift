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
    static var snapshotHistoryCache: [SnapshotHistoryKey<ChartEntryKind> : ChartSnapshotHistory] = [:]
    static var overallHistoryCache: [OverallHistoryKey<ChartEntryKind> : ChartOverallHistory] = [:]
    static var yearEndChartCache: [YearEndChartKey : [YearEndChartEntry]] = [:]
    static var allTimeChartCache: [ChartMetric : [AllTimeChartEntry]] = [:]
}
