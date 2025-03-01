//
//  AllTimeChartsViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/21/25.
//

import Combine
import Foundation

protocol AllTimeChartsViewModelProtocol: ObservableObject {
    init()
    func generateAllTimeTrackChart(metric: ChartMetric, artistLimit: Int?) async -> [AllTimeChartEntryUIModel]
    func generateAllTimeAlbumChart(metric: ChartMetric, artistLimit: Int?) async -> [AllTimeChartEntryUIModel]
    func generateAllTimeArtistChart(metric: ChartMetric) async -> [AllTimeChartEntryUIModel]
}

final class AllTimeChartsViewModel: AllTimeChartsViewModelProtocol {
    private var cancellables: Set<AnyCancellable> = []

    func generateAllTimeTrackChart(metric: ChartMetric, artistLimit: Int?) async -> [AllTimeChartEntryUIModel] {
        await withCheckedContinuation { continuation in
            TrackChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        return TrackChartRepository.generateAllTimeChart(metric: metric, artistLimit: artistLimit).map {
            AllTimeChartEntryUIModel(entry: $0)
        }
    }

    func generateAllTimeAlbumChart(metric: ChartMetric, artistLimit: Int?) async -> [AllTimeChartEntryUIModel] {
        await withCheckedContinuation { continuation in
            AlbumChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        return AlbumChartRepository.generateAllTimeChart(metric: metric, artistLimit: artistLimit).map {
            AllTimeChartEntryUIModel(entry: $0)
        }
    }

    func generateAllTimeArtistChart(metric: ChartMetric) async -> [AllTimeChartEntryUIModel] {
        await withCheckedContinuation { continuation in
            ArtistChartRepository.allCharts
                .filter { !$0.isEmpty }
                .first()
                .sink { _ in
                    continuation.resume(returning: ())
                }
                .store(in: &cancellables)
        }

        return ArtistChartRepository.generateAllTimeChart(metric: metric).map {
            AllTimeChartEntryUIModel(entry: $0)
        }
    }
}
