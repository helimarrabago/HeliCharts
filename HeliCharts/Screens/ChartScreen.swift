//
//  ChartScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import SwiftUI

struct ChartScreen<ViewModel: ChartsViewModelProtocol>: View {
    let topChartEntry: TopChartEntryUIModel

    @StateObject private var viewModel = ViewModel()
    @State private var chart: ChartUIModel?

    private var entries: [ChartEntryUIModel] {
        return chart?.entries ?? []
    }

    var body: some View {
        List {
            Section {
                ForEach(entries) { entry in
                    NavigationLink {
                        ChartEntryDetailsScreen<ChartEntryDetailsViewModel>(entry: entry.parent, year: nil)
                    } label: {
                        HStack(alignment: .top) {
                            VStack {
                                Text(entry.rank)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text(entry.movement.symbol)
                                    .font(.footnote)
                                    .foregroundStyle(entry.movement.color)
                            }
                            .frame(width: 40)

                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text(entry.title)
                                        .font(.headline)

                                    HStack {
                                        Text("Peak: \(entry.peak)")
                                            .font(.caption)

                                        Text("Weeks: \(entry.weeks)")
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

                                    Text("Total Units: " + entry.units)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            } header: {
                VStack(alignment: .center) {
                    Text("Week \(topChartEntry.weekNumber)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)

                    Text(topChartEntry.week)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .navigationTitle(topChartEntry.kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            chart = await viewModel.generateDetailedChart(for: topChartEntry)
        }
    }
}

#Preview {
    final class MockViewModel: ChartsViewModelProtocol {
        // swiftlint:disable function_body_length
        func generateDetailedChart(for topChart: TopChartEntryUIModel) async -> ChartUIModel {
            return ChartUIModel(id: "", week: "Jan 10, 2024 to Jan 16, 2024", entries: [
                ChartEntryUIModel(
                    id: "1",
                    rank: "1",
                    movement: ChartMovementUIModel(movement: .upwards(value: 3)),
                    title: "Beyoncé - Formation",
                    streams: "100,000,000",
                    sales: "120,000",
                    units: "220,000",
                    peak: "#1 (4x)",
                    weeks: "64",
                    parent: MockChartEntry()),
                ChartEntryUIModel(
                    id: "2",
                    rank: "2",
                    movement: ChartMovementUIModel(movement: .downward(value: 1)),
                    title: "Beyoncé - II Most Wanted (feat. Miley Cyrus)",
                    streams: "90,000,000",
                    sales: "110,000",
                    units: "200,000",
                    peak: "#1 (2x)",
                    weeks: "3",
                    parent: MockChartEntry()),
                ChartEntryUIModel(
                    id: "3",
                    rank: "3",
                    movement: ChartMovementUIModel(movement: .reappear),
                    title: "Beyoncé - Crazy in Love (feat. Jay Z)",
                    streams: "80,000,000",
                    sales: "100,000",
                    units: "180,000",
                    peak: "#1 (8x)",
                    weeks: "142",
                    parent: MockChartEntry()),
                ChartEntryUIModel(
                    id: "4",
                    rank: "4",
                    movement: ChartMovementUIModel(movement: .stay),
                    title: "Beyoncé - AMERIICAN REQUIEM",
                    streams: "70,000,000",
                    sales: "102,000",
                    units: "172,000",
                    peak: "#1 (5x)",
                    weeks: "8",
                    parent: MockChartEntry()),
                ChartEntryUIModel(
                    id: "5",
                    rank: "5",
                    movement: ChartMovementUIModel(movement: .reappear),
                    title: "Beyoncé - Partition",
                    streams: "60,000,000",
                    sales: "90,000",
                    units: "150,000",
                    peak: "#1 (2x)",
                    weeks: "64",
                    parent: MockChartEntry())
            ], kind: .track, chart: MockChart())
        }
        // swiftlint:enable function_body_length
    }

    return NavigationView {
        ChartScreen<MockViewModel>(topChartEntry: TopChartEntryUIModel(
            id: "",
            title: nil,
            streams: nil,
            sales: nil,
            units: nil,
            weekNumber: "1",
            week: "Jan 2, 2024 - Jan 9, 2024",
            kind: .track,
            chart: MockChart()))
    }
}
