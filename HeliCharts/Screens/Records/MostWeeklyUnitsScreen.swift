//
//  MostWeeklyUnitsScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/2/25.
//

import SwiftUI

struct MostWeeklyUnitsScreen<ViewModel: MostWeeklyUnitsViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var chartMetric: ChartMetric = .totalUnits
    @State private var chartKind: ChartKind = .track
    @State private var tracks: [MostWeeklyUnitsUIModel] = []
    @State private var albums: [MostWeeklyUnitsUIModel] = []
    @State private var artists: [MostWeeklyUnitsUIModel] = []
    @State private var loading = true

    var body: some View {
        Group {
            if loading {
                ProgressView()
            } else {
                List {
                    Section {
                        switch chartKind {
                        case .track: chartList(for: tracks)
                        case .album: chartList(for: albums)
                        case .artist: chartList(for: artists)
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 2) {
                            chartMetricPicker
                            chartKindPicker
                        }
                        .padding(.bottom, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Most units in a single week")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard loading else { return }
            await getMostWeeklyUnits()
            withAnimation {
                self.loading = false
            }
        }
        .onChange(of: chartKind) { _, _ in
            Task {
                await getMostWeeklyUnits()
            }
        }
        .onChange(of: chartMetric) { _, _ in
            Task {
                await getMostWeeklyUnits()
            }
        }
    }

    private func getMostWeeklyUnits() async {
        switch chartKind {
        case .track:
            let tracks = await viewModel.fetchMostWeeklyTrackUnits(metric: chartMetric)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.fetchMostWeeklyAlbumUnits(metric: chartMetric)
            withAnimation {
                self.albums = albums
            }
        case .artist:
            let artists = await viewModel.fetchMostWeeklyArtistUnits(metric: chartMetric)
            withAnimation {
                self.artists = artists
            }
        }
    }
}

private extension MostWeeklyUnitsScreen {
    var chartMetricPicker: some View {
        HStack(spacing: 0) {
            Text("Metric:")
                .font(.callout)
                .fontWeight(.semibold)

            Picker("Metric", selection: $chartMetric) {
                ForEach(ChartMetric.allCases, id: \.self) { metric in
                    Text(metric.name)
                }
            }
        }
    }

    var chartKindPicker: some View {
        Picker("Chart type", selection: $chartKind.animation()) {
            ForEach(ChartKind.allCases, id: \.self) { type in
                type.image
            }
        }
        .pickerStyle(.segmented)
    }

    func chartList(for entries: [MostWeeklyUnitsUIModel]) -> some View {
        ForEach(entries) { entry in
            HStack(alignment: .top) {
                Text(entry.rank)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text(entry.name)
                            .font(.headline)

                        HStack {
                            Text("Position: #" + entry.position)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)

                            Text("Week: " + entry.week)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Streams: " + entry.streams)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)

                            Text("Sales: " + entry.sales)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)
                        }

                        Text("Total Units: " + entry.totalUnits)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    final class MockViewModel: MostWeeklyUnitsViewModelProtocol {
        func fetchMostWeeklyTrackUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
            return [
                MostWeeklyUnitsUIModel(
                    name: "Beyoncé - Formation",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    totalUnits: "220,000",
                    position: "1",
                    week: "Jan 31, 2025 to Feb 6, 2025")
            ]
        }

        func fetchMostWeeklyAlbumUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
            return [
                MostWeeklyUnitsUIModel(
                    name: "Beyoncé - Lemonade",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    totalUnits: "220,000",
                    position: "1",
                    week: "Jan 31, 2025 to Feb 6, 2025")
            ]
        }

        func fetchMostWeeklyArtistUnits(metric: ChartMetric) async -> [MostWeeklyUnitsUIModel] {
            return [
                MostWeeklyUnitsUIModel(
                    name: "Beyoncé",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    totalUnits: "220,000",
                    position: "1",
                    week: "Jan 31, 2025 to Feb 6, 2025")
            ]
        }
    }

    return NavigationView {
        MostWeeklyUnitsScreen(viewModel: MockViewModel())
    }
}
