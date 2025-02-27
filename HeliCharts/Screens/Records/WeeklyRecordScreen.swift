//
//  WeeklyRecordScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/2/25.
//

import SwiftUI

struct WeeklyRecordScreen<ViewModel: WeeklyRecordViewModelProtocol>: View {
    let recordType: WeeklyRecordType

    @ObservedObject var viewModel: ViewModel
    @State private var chartMetric: ChartMetric = .totalUnits
    @State private var chartKind: ChartKind = .track
    @State private var tracks: [WeeklyRecordUIModel] = []
    @State private var albums: [WeeklyRecordUIModel] = []
    @State private var artists: [WeeklyRecordUIModel] = []
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
        .navigationTitle(navigationTitle)
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
            let tracks = await viewModel.fetchWeeklyTrackRecord(type: recordType, metric: chartMetric)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.fetchWeeklyAlbumRecord(type: recordType, metric: chartMetric)
            withAnimation {
                self.albums = albums
            }
        case .artist:
            let artists = await viewModel.fetchWeeklyArtistRecord(type: recordType, metric: chartMetric)
            withAnimation {
                self.artists = artists
            }
        }
    }
}

private extension WeeklyRecordScreen {
    var navigationTitle: String {
        switch recordType {
        case .mostWeeklyUnits:
            return "Most units in a single week"
        case .biggestDebuts:
            return "Biggest debuts"
        case .biggestPeaks:
            return "Biggest peaks"
        }
    }

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

    func chartList(for entries: [WeeklyRecordUIModel]) -> some View {
        ForEach(entries) { entry in
            HStack(alignment: .top) {
                Text(entry.rank)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text(entry.name)
                            .font(.headline)

                        HStack {
                            Text("Position: #" + entry.position)
                                .font(.caption)
                                .foregroundStyle(Color.secondary)

                            Text("Chart: " + entry.week)
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
    final class MockViewModel: WeeklyRecordViewModelProtocol {
        func fetchWeeklyTrackRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
            return [
                WeeklyRecordUIModel(
                    name: "Beyoncé - Formation",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    totalUnits: "220,000",
                    position: "1",
                    week: "Jan 31, 2025 to Feb 6, 2025")
            ]
        }

        func fetchWeeklyAlbumRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
            return [
                WeeklyRecordUIModel(
                    name: "Beyoncé - Lemonade",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    totalUnits: "220,000",
                    position: "1",
                    week: "Jan 31, 2025 to Feb 6, 2025")
            ]
        }

        func fetchWeeklyArtistRecord(type: WeeklyRecordType, metric: ChartMetric) async -> [WeeklyRecordUIModel] {
            return [
                WeeklyRecordUIModel(
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
        WeeklyRecordScreen(recordType: .mostWeeklyUnits, viewModel: MockViewModel())
    }
}
