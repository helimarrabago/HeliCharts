//
//  YearEndChartsScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/13/25.
//

import SwiftUI

struct YearEndChartsScreen<ViewModel: YearEndChartsViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var loading = true
    @State private var years: [Int] = []
    @State private var selectedYear: Int = 0
    @State private var chartMetric: ChartMetric = .totalUnits
    @State private var chartKind: ChartKind = .track
    @State private var tracks: [YearEndChartEntryUIModel] = []
    @State private var albums: [YearEndChartEntryUIModel] = []
    @State private var artists: [YearEndChartEntryUIModel] = []

    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Year-end charts")
        }
        .task {
            guard loading else { return }
            let years = await viewModel.getYears()
            withAnimation {
                self.loading = false
                self.selectedYear = years.last!
                self.years = years
            }
        }
        .onChange(of: selectedYear) { _, _ in
            Task {
                await generateYearEndChart()
            }
        }
        .onChange(of: chartMetric) { _, _ in
            Task {
                await generateYearEndChart()
            }
        }
        .onChange(of: chartKind) { _, _ in
            Task {
                await generateYearEndChart()
            }
        }
    }

    private func generateYearEndChart() async {
        switch chartKind {
        case .track:
            let tracks = await viewModel.generateYearEndTrackChart(for: selectedYear, metric: chartMetric)
            withAnimation {
                self.tracks = tracks
            }
        case .album:
            let albums = await viewModel.generateYearEndAlbumChart(for: selectedYear, metric: chartMetric)
            withAnimation {
                self.albums = albums
            }
        case .artist:
            let artists = await viewModel.generateYearEndArtistChart(for: selectedYear, metric: chartMetric)
            withAnimation {
                self.artists = artists
            }
        }
    }
}

private extension YearEndChartsScreen {
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
                            yearsPicker
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

    var yearsPicker: some View {
        HStack(spacing: 0) {
            Text("Year:")
                .font(.callout)
                .fontWeight(.semibold)

            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(year))
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

    func chartList(for entries: [YearEndChartEntryUIModel]) -> some View {
        ForEach(entries) { entry in
            NavigationLink {
                ChartEntryDetailsScreen<ChartEntryDetailsViewModel>(entry: entry.parent, year: selectedYear)
            } label: {
                ChartEntryDetailCell(entry: entry)
            }
        }
    }
}

#Preview {
    final class MockViewModel: YearEndChartsViewModelProtocol {
        func getYears() async -> [Int] {
            return [2023, 2024, 2025]
        }

        func generateYearEndTrackChart(for year: Int, metric: ChartMetric) -> [YearEndChartEntryUIModel] {
            return [YearEndChartEntryUIModel(
                id: "1",
                title: "Beyoncé - 6 Inch (feat. The Weeknd)",
                rank: "1",
                movement: ChartMovementUIModel(movement: .upwards(value: 3)),
                peak: "#1 (2x)",
                weeks: "21",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }

        func generateYearEndAlbumChart(for year: Int, metric: ChartMetric) -> [YearEndChartEntryUIModel] {
            return [YearEndChartEntryUIModel(
                id: "1",
                title: "Cowboy Carter",
                rank: "1",
                movement: ChartMovementUIModel(movement: .upwards(value: 3)),
                peak: "#1 (11x)",
                weeks: "32",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }

        func generateYearEndArtistChart(for year: Int, metric: ChartMetric) -> [YearEndChartEntryUIModel] {
            return [YearEndChartEntryUIModel(
                id: "1",
                title: "Beyoncé",
                rank: "1",
                movement: ChartMovementUIModel(movement: .upwards(value: 3)),
                peak: "#1 (34x)",
                weeks: "54",
                streams: "2.1 B",
                sales: "1.9 M",
                units: "10,000,000",
                certifications: [.diamond(count: 1), .platinum(count: 2)],
                parent: MockChartEntry())]
        }
    }

    return YearEndChartsScreen(viewModel: MockViewModel())
}
