//
//  FastestRecordScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 3/1/25.
//

import SwiftUI

struct FastestRecordScreen<ViewModel: FastestRecordViewModelProtocol>: View {
    let recordType: FastestRecordType

    @ObservedObject var viewModel: ViewModel
    @State private var milestone: FastestRecordMilestone
    @State private var chartMetric: ChartMetric
    @State private var chartKind: ChartKind = .track
    @State private var tracks: [FastestRecordUIModel] = []
    @State private var albums: [FastestRecordUIModel] = []
    @State private var artists: [FastestRecordUIModel] = []
    @State private var loading = true

    init(recordType: FastestRecordType, viewModel: ViewModel) {
        self.recordType = recordType
        self.viewModel = viewModel

        switch recordType {
        case .milestoneUnits:
            self.milestone = .units(metric: .totalUnits, value: 500_000)
            self.chartMetric = .totalUnits
        }
    }

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
                            VStack(alignment: .leading, spacing: -8) {
                                milestonePicker
                                chartMetricPicker
                            }
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
            await getFastestRecord()
            withAnimation {
                self.loading = false
            }
        }
        .onChange(of: chartKind) { _, _ in
            Task {
                await getFastestRecord()
            }
        }
        .onChange(of: chartMetric) { _, _ in
            Task {
                await getFastestRecord()
            }
        }
        .onChange(of: milestone) { _, _ in
            Task {
                await getFastestRecord()
            }
        }
    }

    private func getFastestRecord() async {
        switch chartKind {
        case .track:
            let tracks = await viewModel.fetchFastestTrackRecord(type: recordType, milestone: milestone)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.fetchFastestAlbumRecord(type: recordType, milestone: milestone)
            withAnimation {
                self.albums = albums
            }
        case .artist:
            let artists = await viewModel.fetchFastestArtistRecord(type: recordType, milestone: milestone)
            withAnimation {
                self.artists = artists
            }
        }
    }

    private func getMilestones() -> [FastestRecordMilestone] {
        switch chartMetric {
        case .totalUnits:
            switch chartKind {
            case .track:
                var values = [500_000]
                values += Array(stride(from: 1_000_000, through: 10_000_000, by: 1_000_000))
                return values.compactMap { FastestRecordMilestone.units(metric: .totalUnits, value: $0) }
            case .album:
                var values = [500_000]
                values += Array(stride(from: 1_000_000, through: 20_000_000, by: 1_000_000))
                return values.compactMap { FastestRecordMilestone.units(metric: .totalUnits, value: $0) }
            case .artist:
                var values = [500_000]
                values += Array(stride(from: 1_000_000, through: 40_000_000, by: 1_000_000))
                return values.compactMap { FastestRecordMilestone.units(metric: .totalUnits, value: $0) }
            }
        case .streams:
            return []
        case .sales:
            return []
        }
    }
}

private extension FastestRecordScreen {
    var navigationTitle: String {
        switch recordType {
        case .milestoneUnits:
            "Fastest to reach milestone units"
        }
    }

    var milestonePicker: some View {
        return HStack(spacing: 0) {
            Text("Milestone:")
                .font(.callout)
                .fontWeight(.semibold)

            Picker("Milestone", selection: $milestone) {
                ForEach(getMilestones(), id: \.self) { milestone in
                    Text(milestone.displayName)
                }
            }
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

    func chartList(for entries: [FastestRecordUIModel]) -> some View {
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
                            Text("Weeks: \(entry.weekCount)")
                                .font(.caption)

                            Text("Chart: " + entry.week)
                                .font(.caption)
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

                        Text("Total Units: " + entry.runningUnits)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    final class MockViewModel: FastestRecordViewModelProtocol {
        func fetchFastestTrackRecord(
            type: FastestRecordType,
            milestone: FastestRecordMilestone
        ) async -> [FastestRecordUIModel] {
            return [
                FastestRecordUIModel(
                    name: "Beyoncé - Formation",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    runningUnits: "220,000",
                    week: "Jan 31, 2025 to Feb 6, 2025",
                    weekCount: "1 week")
            ]
        }

        func fetchFastestAlbumRecord(
            type: FastestRecordType,
            milestone: FastestRecordMilestone
        ) async -> [FastestRecordUIModel] {
            return [
                FastestRecordUIModel(
                    name: "Beyoncé - Lemonade",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    runningUnits: "220,000",
                    week: "Jan 31, 2025 to Feb 6, 2025",
                    weekCount: "1 week")
            ]
        }

        func fetchFastestArtistRecord(
            type: FastestRecordType,
            milestone: FastestRecordMilestone
        ) async -> [FastestRecordUIModel] {
            return [
                FastestRecordUIModel(
                    name: "Beyoncé",
                    rank: "1",
                    streams: "100,000,000",
                    sales: "120,000",
                    runningUnits: "220,000",
                    week: "Jan 31, 2025 to Feb 6, 2025",
                    weekCount: "1 week")
            ]
        }
    }

    return NavigationView {
        FastestRecordScreen(recordType: .milestoneUnits, viewModel: MockViewModel())
    }
}
