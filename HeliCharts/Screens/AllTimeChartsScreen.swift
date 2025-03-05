//
//  AllTimeChartsScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/21/25.
//

import SwiftUI

struct AllTimeChartsScreen<ViewModel: AllTimeChartsViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var loading = true
    @State private var chartMetric: ChartMetric = .totalUnits
    @State private var artistLimit: Int?
    @State private var chartKind: ChartKind = .track
    @State private var tracks: [AllTimeChartEntryUIModel] = []
    @State private var albums: [AllTimeChartEntryUIModel] = []
    @State private var artists: [AllTimeChartEntryUIModel] = []

    @FocusState private var isArtistLimitFocused: Bool
    @State private var artistLimitFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("All-time charts")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isArtistLimitFocused = false
                }
             }
        }
        .task {
            guard loading else { return }
            await generateAllTimeChart()
            withAnimation {
                self.loading = false
            }
        }
        .onChange(of: chartKind) { _, _ in
            Task {
                await generateAllTimeChart()
            }
        }
        .onChange(of: chartMetric) { _, _ in
            Task {
                await generateAllTimeChart()
            }
        }
    }

    private func generateAllTimeChart() async {
        switch chartKind {
        case .track:
            let tracks = await viewModel.generateAllTimeTrackChart(
                metric: chartMetric,
                artistLimit: artistLimit)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.generateAllTimeAlbumChart(
                metric: chartMetric,
                artistLimit: artistLimit)
            withAnimation {
                self.albums = albums
            }
        case .artist:
            let artists = await viewModel.generateAllTimeArtistChart(metric: chartMetric)
            withAnimation {
                self.artists = artists
            }
        }
    }
}

private extension AllTimeChartsScreen {
    @ViewBuilder
    var contentView: some View {
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
                        HStack {
                            chartMetricPicker
                            artistLimitTextField
                        }
                        chartKindPicker
                    }
                    .padding(.bottom, 4)
                }
            }
            .listStyle(.plain)
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

    var artistLimitTextField: some View {
        HStack {
            Text("Artist limit:")
                .font(.callout)
                .fontWeight(.semibold)

            TextField("—", value: $artistLimit, formatter: artistLimitFormatter) {
                Task {
                    await generateAllTimeChart()
                }
            }
            .focused($isArtistLimitFocused)
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

    func chartList(for entries: [AllTimeChartEntryUIModel]) -> some View {
        ForEach(entries) { entry in
            NavigationLink {
                ChartEntryDetailsScreen<ChartEntryDetailsViewModel>(entry: entry.parent, year: nil)
            } label: {
                ChartEntryDetailCell(entry: entry)
            }
        }
    }
}

#Preview {
    final class MockViewModel: AllTimeChartsViewModelProtocol {
        func generateAllTimeTrackChart(
            metric: ChartMetric,
            artistLimit: Int?
        ) async -> [AllTimeChartEntryUIModel] {
            return [AllTimeChartEntryUIModel(
                id: "1",
                title: "Beyoncé - 6 Inch (feat. The Weeknd)",
                rank: "1",
                peak: "#1 (2x)",
                weeks: "21",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }

        func generateAllTimeAlbumChart(
            metric: ChartMetric,
            artistLimit: Int?
        ) async -> [AllTimeChartEntryUIModel] {
            return [AllTimeChartEntryUIModel(
                id: "1",
                title: "Cowboy Carter",
                rank: "1",
                peak: "#1 (11x)",
                weeks: "32",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }

        func generateAllTimeArtistChart(metric: ChartMetric) async -> [AllTimeChartEntryUIModel] {
            return [AllTimeChartEntryUIModel(
                id: "1",
                title: "Beyoncé",
                rank: "1",
                peak: "#1 (34x)",
                weeks: "54",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }
    }

    return AllTimeChartsScreen(viewModel: MockViewModel())
}
