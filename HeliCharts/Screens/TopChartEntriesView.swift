//
//  TopChartEntriesView.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/13/25.
//

import SwiftUI

struct TopChartEntriesView<ViewModel: TopChartEntriesViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var loading = true
    @State private var chartType: TopChartKind = .track
    @State private var user: UserUIModel?
    @State private var topTracks: [TopChartEntryUIModel] = []
    @State private var topAlbums: [TopChartEntryUIModel] = []
    @State private var topArtists: [TopChartEntryUIModel] = []
    @State private var topOverall: [OverallTopChartEntryUIModel] = []

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle(navigationTitle)
        }
        .task {
            guard loading else { return }

            do {
                let user = await viewModel.fetchUser()
                withAnimation {
                    self.user = user
                }

                let topTracks = try await viewModel.fetchTopTracks()
                let topAlbums = try await viewModel.fetchTopAlbums()
                let topArtists = try await viewModel.fetchTopArtists()
                let topOverall = await viewModel.generateTopOverall()

                withAnimation {
                    self.loading = false
                    self.topTracks = topTracks
                    self.topAlbums = topAlbums
                    self.topArtists = topArtists
                    self.topOverall = topOverall
                }
            } catch {
                print(error)
            }
        }
    }
}

private extension TopChartEntriesView {
    private var navigationTitle: String {
        return [user?.name, "charts"].compactMap { $0 }.joined(separator: " ")
    }

    @ViewBuilder
    var contentView: some View {
        if loading {
            ZStack {
                List {
                    Section {
                    } header: {
                        chartTypePicker
                    }
                }
                .listStyle(.plain)

                ProgressView()
                    .frame(maxHeight: .infinity)
            }
        } else {
            List {
                Section {
                    switch chartType {
                    case .track: chartsList(for: topTracks)
                    case .album: chartsList(for: topAlbums)
                    case .artist: chartsList(for: topArtists)
                    case .overall: overallChartList
                    }
                } header: {
                    chartTypePicker
                }
            }
            .listStyle(.plain)
        }
    }

    var chartTypePicker: some View {
        Picker("Select chart type", selection: $chartType.animation()) {
            ForEach(TopChartKind.allCases, id: \.self) { type in
                type.image
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
    }

    func chartsList(for charts: [TopChartEntryUIModel]) -> some View {
        ForEach(charts) { chart in
            NavigationLink {
                ChartView<ChartViewModel>(topChartEntry: chart)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Week \(chart.weekNumber)")
                                .font(.headline)

                            Text(chart.week)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let title = chart.title {
                            Text(chart.kind.emoji + " " + title)
                                .font(.headline)
                        } else {
                            placeholderText
                        }
                    }

                    if let streams = chart.streams,
                       let sales = chart.sales,
                       let units = chart.units {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Streams: " + streams)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)

                                Text("Sales: " + sales)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }

                            Text("Total Units: " + units)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }

    var overallChartList: some View {
        ForEach(topOverall) { chart in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Week \(chart.weekNumber)")
                        .font(.headline)

                    Text(chart.week)
                        .font(.caption)
                }

                if let trackTitle = chart.trackTitle,
                   let trackUnits = chart.trackUnits,
                   let albumTitle = chart.albumTitle,
                   let albumUnits = chart.albumUnits,
                   let artistTitle = chart.artistTitle,
                   let artistUnits = chart.artistUnits {
                    VStack(alignment: .leading) {
                        Text(ChartKind.track.emoji + " " + trackTitle)
                            .font(.callout)
                            .fontWeight(.semibold)

                        Text("Units: " + trackUnits)
                            .font(.caption)
                    }

                    VStack(alignment: .leading) {
                        Text(ChartKind.album.emoji + " " + albumTitle)
                            .font(.callout)
                            .fontWeight(.semibold)

                        Text("Units: " + albumUnits)
                            .font(.caption)
                    }

                    VStack(alignment: .leading) {
                        Text(ChartKind.artist.emoji + " " + artistTitle)
                            .font(.callout)
                            .fontWeight(.semibold)

                        Text("Units: " + artistUnits)
                            .font(.caption)
                    }
                } else {
                    placeholderText
                }
            }
        }
    }

    var placeholderText: some View {
        Text("Nothing to display")
            .font(.headline)
            .fontWeight(.regular)
            .italic()
            .foregroundStyle(Color.secondary)
    }
}

#Preview {
    final class MockViewModel: TopChartEntriesViewModelProtocol {
        let topTrack = TopChartEntryUIModel(
            id: "",
            title: "Beyoncé - Formation",
            streams: "100,000,000",
            sales: "110,000",
            units: "210,000",
            weekNumber: "1",
            week: "Jan 2, 2025 - Jan 9, 2025",
            kind: .track,
            chart: MockChart())
        let topAlbum = TopChartEntryUIModel(
            id: "",
            title: "Beyoncé - Lemonade",
            streams: "300,000,000",
            sales: "210,000",
            units: "510,000",
            weekNumber: "1",
            week: "Jan 2, 2025 - Jan 9, 2025",
            kind: .album,
            chart: MockChart())
        let topArtist = TopChartEntryUIModel(
            id: "",
            title: "Beyoncé",
            streams: "500,000,000",
            sales: "310,000",
            units: "810,000",
            weekNumber: "1",
            week: "Jan 2, 2025 - Jan 9, 2025",
            kind: .artist,
            chart: MockChart())

        func fetchUser() async -> UserUIModel {
            return UserUIModel(name: "helimarrabago")
        }

        func fetchTopTracks() async throws -> [TopChartEntryUIModel] {
            return [topTrack]
        }

        func fetchTopAlbums() async throws -> [TopChartEntryUIModel] {
            return [topAlbum]
        }

        func fetchTopArtists() async throws -> [TopChartEntryUIModel] {
            return [topArtist]
        }

        func generateTopOverall() async -> [OverallTopChartEntryUIModel] {
            return [OverallTopChartEntryUIModel(topTrack: topTrack, topAlbum: topAlbum, topArtist: topArtist)]
        }
    }

    return TopChartEntriesView(viewModel: MockViewModel())
}
