//
//  YearEndChartsViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/13/25.
//

import Combine
import Foundation

protocol YearEndChartsViewModelProtocol: ObservableObject {
    init()
    func getYears() async -> [Int]
    func generateYearEndTrackChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel]
    func generateYearEndAlbumChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel]
    func generateYearEndArtistChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel]
}

final class YearEndChartsViewModel: YearEndChartsViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = []

    func getYears() async -> [Int] {
        await withCheckedContinuation { continuation in
            TrackChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        await withCheckedContinuation { continuation in
            AlbumChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        await withCheckedContinuation { continuation in
            ArtistChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        let startDate = TrackChartRepository.allCharts.value.last!.week.from
        return DateHelper.getYears(from: TimeInterval(startDate))
    }

    func generateYearEndTrackChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel] {
        return TrackChartRepository.generateYearEndChart(for: year, metric: metric).map {
            YearEndChartEntryUIModel(entry: $0)
        }
    }

    func generateYearEndAlbumChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel] {
        return AlbumChartRepository.generateYearEndChart(for: year, metric: metric).map {
            YearEndChartEntryUIModel(entry: $0)
        }
    }

    func generateYearEndArtistChart(for year: Int, metric: ChartMetric) async -> [YearEndChartEntryUIModel] {
        return ArtistChartRepository.generateYearEndChart(for: year, metric: metric).map {
            YearEndChartEntryUIModel(entry: $0)
        }
    }
}
