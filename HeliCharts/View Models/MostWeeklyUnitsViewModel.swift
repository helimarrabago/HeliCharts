//
//  MostWeeklyUnitsViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/3/25.
//

import Foundation

protocol MostWeeklyUnitsViewModelProtocol: ObservableObject {
    func fetchMostWeeklyTrackUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel]
    func fetchMostWeeklyAlbumUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel]
    func fetchMostWeeklyArtistUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel]
}

final class MostWeeklyUnitsViewModel: MostWeeklyUnitsViewModelProtocol {
    func fetchMostWeeklyTrackUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
        return TrackChartRepository.getMostWeeklyUnits(metric: metric)
            .map { MostWeeklyUnitsUIModel(dataModel: $0) }
    }

    func fetchMostWeeklyAlbumUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
        return AlbumChartRepository.getMostWeeklyUnits(metric: metric)
            .map { MostWeeklyUnitsUIModel(dataModel: $0) }
    }

    func fetchMostWeeklyArtistUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
        return ArtistChartRepository.getMostWeeklyUnits(metric: metric)
            .map { MostWeeklyUnitsUIModel(dataModel: $0) }
    }
}
