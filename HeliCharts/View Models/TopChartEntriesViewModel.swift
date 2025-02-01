//
//  TopChartEntriesViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/13/25.
//

import Combine
import Foundation

protocol TopChartEntriesViewModelProtocol: ObservableObject {
    init()
    func fetchUser() async -> UserUIModel
    func fetchTopTracks() async throws -> [TopChartEntryUIModel]
    func fetchTopAlbums() async throws -> [TopChartEntryUIModel]
    func fetchTopArtists() async throws -> [TopChartEntryUIModel]
    func generateTopOverall() async -> [OverallTopChartEntryUIModel]
}

final class TopChartEntriesViewModel: TopChartEntriesViewModelProtocol {
    private var user: User?
    private var topTracks: [TopChartEntryUIModel] = []
    private var topAlbums: [TopChartEntryUIModel] = []
    private var topArtists: [TopChartEntryUIModel] = []
    private var cancellables: Set<AnyCancellable> = []

    func fetchUser() async -> UserUIModel {
        if let user = user {
            return UserUIModel(user: user)
        }

        let user = await withCheckedContinuation { continuation in
            UserRepository.user
                .compactMap { $0 }
                .first()
                .sink { user in
                    continuation.resume(returning: user)
                }
                .store(in: &cancellables)
        }

        self.user = user
        return UserUIModel(user: user)
    }

    func fetchTopTracks() async throws -> [TopChartEntryUIModel] {
        if !topTracks.isEmpty {
            return topTracks
        }

        let responses = try await withThrowingTaskGroup(of: TrackChartResponse.self) { [weak self] group in
            guard let self else { return [TrackChartResponse]() }

            let weeks = generateWeeks()
            for week in weeks {
                group.addTask {
                    try await self.fetchTrackChart(week: week)
                }
            }

            return try await group.reduce(into: [TrackChartResponse]()) { responses, response in
                responses.append(response)
            }
        }

        let charts = responses.filter { !$0.weeklytrackchart.track.isEmpty }
        let mappedCharts = charts.map { TrackChart(response: $0) }
        let sortedCharts = mappedCharts.sorted { $0.week.from > $1.week.from }

        TrackChartRepository.allCharts.send(sortedCharts)
        topTracks = sortedCharts.map { TopChartEntryUIModel(chart: $0) }

        return topTracks
    }

    func fetchTopAlbums() async throws -> [TopChartEntryUIModel] {
        if !topAlbums.isEmpty {
            return topAlbums
        }

        let responses = try await withThrowingTaskGroup(of: AlbumChartResponse.self) { [weak self] group in
            guard let self else { return [AlbumChartResponse]() }

            let weeks = generateWeeks()
            for week in weeks {
                group.addTask {
                    try await self.fetchAlbumChart(week: week)
                }
            }

            return try await group.reduce(into: [AlbumChartResponse]()) { responses, response in
                responses.append(response)
            }
        }

        let charts = responses.filter { !$0.weeklyalbumchart.album.isEmpty }
        let mappedCharts = charts.map { AlbumChart(response: $0) }
        let sortedCharts = mappedCharts.sorted { return $0.week.from > $1.week.from }

        AlbumChartRepository.allCharts.send(sortedCharts)
        topAlbums = sortedCharts.map { TopChartEntryUIModel(chart: $0) }

        return topAlbums
    }

    func fetchTopArtists() async throws -> [TopChartEntryUIModel] {
        if !topArtists.isEmpty {
            return topArtists
        }

        let responses = try await withThrowingTaskGroup(of: ArtistChartResponse.self) { [weak self] group in
            guard let self else { return [ArtistChartResponse]() }

            let weeks = generateWeeks()
            for week in weeks {
                group.addTask {
                    try await self.fetchArtistChart(week: week)
                }
            }

            return try await group.reduce(into: [ArtistChartResponse]()) { responses, response in
                responses.append(response)
            }
        }

        let charts = responses.filter { !$0.weeklyartistchart.artist.isEmpty }
        let mappedCharts = charts.map { ArtistChart(response: $0) }
        let sortedCharts = mappedCharts.sorted { $0.week.from > $1.week.from }

        ArtistChartRepository.allCharts.send(sortedCharts)
        topArtists = sortedCharts.map { TopChartEntryUIModel(chart: $0) }

        return topArtists
    }

    func generateTopOverall() async -> [OverallTopChartEntryUIModel] {
        let topOverall = topTracks.enumerated().map { index, topTrack in
            let topAbum = topAlbums[index]
            let topArtist = topArtists[index]
            return OverallTopChartEntryUIModel(topTrack: topTrack, topAlbum: topAbum, topArtist: topArtist)
        }
        return topOverall
    }
}

private extension TopChartEntriesViewModel {
    func generateWeeks() -> [WeekRange] {
        guard let user = user else { return [] }
        let fromDate = TimeInterval(user.registeredDate)
        let weeks = DateHelper.getWeeks(from: fromDate)
        return weeks
    }

    func fetchTrackChart(week: WeekRange) async throws -> TrackChartResponse {
        let url = LastFM.createURL(
            method: .userWeeklyTrackChart,
            params: ["from": Int(week.from), "to": Int(week.to)],
            limit: Settings.trackChartLimit)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TrackChartResponse.self, from: data)
        return response
    }

    func fetchAlbumChart(week: WeekRange) async throws -> AlbumChartResponse {
        let url = LastFM.createURL(
            method: .userWeeklyAlbumChart,
            params: ["from": Int(week.from), "to": Int(week.to)],
            limit: Settings.albumChartLimit)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AlbumChartResponse.self, from: data)
        return response
    }

    func fetchArtistChart(week: WeekRange) async throws -> ArtistChartResponse {
        let url = LastFM.createURL(
            method: .userWeeklyArtistChart,
            params: ["from": Int(week.from), "to": Int(week.to)],
            limit: Settings.artistChartLimit)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ArtistChartResponse.self, from: data)
        return response
    }
}
