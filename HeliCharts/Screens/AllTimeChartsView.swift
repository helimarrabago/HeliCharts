//
//  AllTimeChartsView.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/21/25.
//

import SwiftUI

struct AllTimeChartsView<ViewModel: AllTimeChartsViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var loading = true
    @State private var chartMetric: ChartMetric = .totalUnits
    @State private var chartType: ChartType = .track
    @State private var tracks: [AllTimeChartEntryUIModel] = []
    @State private var albums: [AllTimeChartEntryUIModel] = []
    @State private var artists: [AllTimeChartEntryUIModel] = []

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("All-time charts")
        }
        .task {
            guard loading else { return }
            await generateAllTimeChart()
            withAnimation {
                self.loading = false
            }
        }
        .onChange(of: chartType) { _, _ in
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
        switch chartType {
        case .track:
            let tracks = await viewModel.generateAllTimeTrackChart(metric: chartMetric)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.generateAllTimeAlbumChart(metric: chartMetric)
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

private extension AllTimeChartsView {
    @ViewBuilder
    var contentView: some View {
        if loading {
            ProgressView()
        } else {
            List {
                Section {
                    switch chartType {
                    case .track: chartList(for: tracks)
                    case .album: chartList(for: albums)
                    case .artist: chartList(for: artists)
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 2) {
                        chartMetricPicker
                        chartTypePicker
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

    var chartTypePicker: some View {
        Picker("Chart type", selection: $chartType.animation()) {
            ForEach(ChartType.allCases, id: \.self) { type in
                type.image
            }
        }
        .pickerStyle(.segmented)
    }

    func chartList(for entries: [AllTimeChartEntryUIModel]) -> some View {
        ForEach(entries) { entry in
            NavigationLink {
                ChartEntryDetailsView<ChartEntryDetailsViewModel>(entry: entry.parent, year: nil)
            } label: {
                ChartEntryDetailedCell(entry: entry)
            }
        }
    }
}

#Preview {
    final class MockViewModel: AllTimeChartsViewModelProtocol {
        func generateAllTimeTrackChart(metric: ChartMetric) async -> [AllTimeChartEntryUIModel] {
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

        func generateAllTimeAlbumChart(metric: ChartMetric) async -> [AllTimeChartEntryUIModel] {
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

    return AllTimeChartsView(viewModel: MockViewModel())
}
