//
//  WeeklyRecordViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/3/25.
//

import Foundation

protocol WeeklyRecordViewModelProtocol: ObservableObject {
    func fetchWeeklyTrackRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel]
    func fetchWeeklyAlbumRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel]
    func fetchWeeklyArtistRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel]
}

final class WeeklyRecordViewModel: WeeklyRecordViewModelProtocol {
    func fetchWeeklyTrackRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
        let weeklyRecords: [WeeklyRecord]
        switch type {
        case .mostWeeklyUnits:
            weeklyRecords = TrackChartRepository.generateMostWeeklyUnitsRecord(metric: metric)
        case .biggestDebuts:
            weeklyRecords = TrackChartRepository.generateBiggestDebutsRecord(metric: metric)
        case .biggestPeaks:
            weeklyRecords = TrackChartRepository.generateBiggestPeaksRecord(metric: metric)
        }

        return weeklyRecords.map { WeeklyRecordUIModel(dataModel: $0) }
    }

    func fetchWeeklyAlbumRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
        let weeklyRecords: [WeeklyRecord]
        switch type {
        case .mostWeeklyUnits:
            weeklyRecords = AlbumChartRepository.generateMostWeeklyUnitsRecord(metric: metric)
        case .biggestDebuts:
            weeklyRecords = AlbumChartRepository.generateBiggestDebutsRecord(metric: metric)
        case .biggestPeaks:
            weeklyRecords = AlbumChartRepository.generateBiggestPeaksRecord(metric: metric)
        }

        return weeklyRecords.map { WeeklyRecordUIModel(dataModel: $0) }
    }

    func fetchWeeklyArtistRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
        let weeklyRecords: [WeeklyRecord]
        switch type {
        case .mostWeeklyUnits:
            weeklyRecords = ArtistChartRepository.generateMostWeeklyUnitsRecord(metric: metric)
        case .biggestDebuts:
            weeklyRecords = ArtistChartRepository.generateBiggestDebutsRecord(metric: metric)
        case .biggestPeaks:
            weeklyRecords = ArtistChartRepository.generateBiggestPeaksRecord(metric: metric)
        }

        return weeklyRecords.map { WeeklyRecordUIModel(dataModel: $0) }
    }
}
