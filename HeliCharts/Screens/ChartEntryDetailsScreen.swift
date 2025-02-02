//
//  ChartEntryDetailsScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import OrderedCollections
import SwiftUI

// swiftlint:disable file_length
struct ChartEntryDetailsScreen<ViewModel: ChartEntryDetailsViewModelProtocol>: View {
    let entry: any ChartEntry
    let year: Int?

    @StateObject private var viewModel = ViewModel()
    @State private var loading = true
    @State private var details: ChartEntryDetailsUIModel?
    private let rows = [GridItem(.flexible(minimum: 192))]

    var body: some View {
        List {
            if loading {
                Section {
                    ProgressView()
                        .padding()
                }
                .listRowSeparator(.hidden)
                .frame(maxWidth: .infinity)
            }

            if let details = details {
                headerView(details: details)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }

            if let certifications = details?.certifications {
                certificationsView(certifications: certifications)
            }

            if let chartRun = details?.chartRun {
                chartRunView(chartRun: chartRun)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }

            if let childEntries = details?.childEntries {
                childEntriesView(childEntries)
            }
        }
        .listStyle(.plain)
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.large)
        .task {
            try? await viewModel.fetchAlbum(from: entry)
            details = await viewModel.generateDetails(of: entry, year: year)
            loading = false
        }
    }
}

private extension ChartEntryDetailsScreen {
    func headerView(details: ChartEntryDetailsUIModel) -> some View {
        Section {
            HStack(spacing: 16) {
                headerImageView
                VStack(alignment: .leading) {
                    if let artistName = details.artistName {
                        headerArtistNameView(name: artistName)
                    }
                    headerPeakAndWeeksView(peak: details.peak, weeks: details.weeks)
                    headerUnitsView(streams: details.streams, sales: details.sales, total: details.totalUnits)
                }
            }
            .padding([.horizontal, .top])
        }
    }

    var headerImageView: some View {
        TopChartKind.track.image
            .frame(width: 108, height: 108)
            .background(Color.blue)
            .clipShape(Circle())
    }

    func headerArtistNameView(name: String) -> some View {
        HStack(alignment: .bottom) {
            Text("ARTIST")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }

    func headerPeakAndWeeksView(peak: String, weeks: String) -> some View {
        HStack {
            HStack(alignment: .bottom) {
                Text("PEAK")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(peak)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            HStack(alignment: .bottom) {
                Text("WEEKS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(weeks)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }

    func headerUnitsView(streams: String, sales: String, total: String) -> some View {
        Group {
            HStack {
                HStack(alignment: .bottom) {
                    Text("STREAMS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(streams)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }

                HStack(alignment: .bottom) {
                    Text("SALES")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(sales)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }

            HStack(alignment: .bottom) {
                Text("TOTAL UNITS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Text(total)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
    }

    func certificationsView(certifications: [Certification]) -> some View {
        let certifications = Array(zip(certifications.indices, certifications))
        return Section {
            HStack {
                ForEach(certifications, id: \.0) { index, certification in
                    HStack {
                        certification.icon
                            .resizable()
                            .frame(width: 48, height: 48)

                        Text(certification.formatted)
                            .font(.headline)

                        if index < certifications.count - 1 {
                            Text("+")
                                .font(.headline)
                        }
                    }
                }
            }
        } header: {
            Text("Certification")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding()
                .listRowInsets(EdgeInsets())
        }
        .listRowSeparator(.hidden)
    }

    func chartRunView(chartRun: [ChartRunSnapshotUIModel]) -> some View {
        let chartRun = Array(zip(chartRun.indices, chartRun))
        return Section {
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: 0) {
                    ForEach(chartRun, id: \.0) { index, snapshot in
                        ChartRunCell(
                            snapshot: snapshot,
                            firstCell: index == 0,
                            lastCell: index == chartRun.count - 1)
                    }
                }
            }
            .scrollIndicators(.hidden)
        } header: {
            Text("Chart Run")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding()
        }
    }

    func childEntriesView(_ childEntries: OrderedDictionary<ChartKind, [ChildChartEntryUIModel]>) -> some View {
        ForEach(childEntries.elements, id: \.key) { element in
            Section {
                childEntriesList(element.value)
            } header: {
                NavigationLink {
                    ChartEntryChildEntriesScreen(entries: element, year: year)
                } label: {
                    Text("Top " + element.key.objects + " ›")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .padding()
                }
                .listRowInsets(EdgeInsets())
            }
        }
    }

    func childEntriesList(_ childEntries: [ChildChartEntryUIModel]) -> some View {
        ForEach(childEntries.prefix(5)) { entry in
            NavigationLink {
                ChartEntryDetailsScreen(entry: entry.parent, year: year)
            } label: {
                ChartEntryDetailCell(entry: entry)
            }
        }
    }
}

private struct ChartRunCell: View {
    let snapshot: ChartRunSnapshotUIModel
    let firstCell: Bool
    let lastCell: Bool

    var body: some View {
        VStack(spacing: 12) {
            switch snapshot {
            case .charted(let position):
                VStack {
                    Text("Week " + position.weekNumber)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text(position.date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 32)

                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(firstCell ? .clear : .white)
                        .frame(height: 0.5)

                    Circle()
                        .frame(width: 8, height: 8)

                    Rectangle()
                        .foregroundStyle(lastCell ? .clear : .white)
                        .frame(height: 0.5)
                }
                .frame(height: 8)

                VStack {
                    VStack(spacing: 8) {
                        VStack {
                            Text("RANK")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(position.rank)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        VStack {
                            Text("UNITS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(position.runningUnits)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("(+\(position.units))")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .frame(width: 132, height: 124)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(uiColor: .separator), lineWidth: 0.8)
                )
                .padding(.horizontal, 8)
            case .outOfChart(let count):
                Spacer(minLength: 32)

                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundStyle(.white)
                        .frame(height: 0.5)
                }
                .frame(height: 8)

                VStack {
                    Text(count)
                        .font(.subheadline)
                        .fontWeight(.bold)

                    Text("out of chart")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(uiColor: .separator), lineWidth: 0.8)
                )
                .frame(height: 126)
                .padding(.horizontal, 8)
            }
        }
    }
}

#Preview {
    final class MockViewModel: ChartEntryDetailsViewModelProtocol {
        func fetchAlbum(from entry: any ChartEntry) async throws {}

        // swiftlint:disable function_body_length
        func generateDetails(of entry: any ChartEntry, year: Int?) -> ChartEntryDetailsUIModel {
            return ChartEntryDetailsUIModel(
                id: "",
                name: "Beyoncé",
                artist: nil,
                streams: "2.0 B",
                sales: "2.0 M",
                totalUnits: "4,046,000",
                weeks: "21",
                peak: "#1 (4x)",
                certifications: [.diamond(count: 1), .platinum(count: 1)],
                chartRun: [
                    .charted(position: ChartPositionUIModel(
                        rank: "#1",
                        units: "200,000",
                        runningUnits: "200,000",
                        date: "Jan 2, 2025",
                        weekNumber: "1")),
                    .charted(position: ChartPositionUIModel(
                        rank: "#5",
                        units: "200,000",
                        runningUnits: "400,000",
                        date: "Jan 9, 2025",
                        weekNumber: "2")),
                    .outOfChart(count: "1x"),
                    .charted(position: ChartPositionUIModel(
                        rank: "#1",
                        units: "200,000",
                        runningUnits: "600,000",
                        date: "Jan 23, 2025",
                        weekNumber: "4"))
                ],
                childEntries: [
                    .album: [
                        ChildChartEntryUIModel(
                            id: "1",
                            title: "Cowboy Carter",
                            rank: "1",
                            peak: "#1 (11x)",
                            weeks: "32",
                            streams: "15,200,000,000",
                            sales: "5,500,000",
                            units: "12,500,000",
                            certifications: [.diamond(count: 1), .platinum(count: 2)],
                            parent: MockChartEntry()),
                        ChildChartEntryUIModel(
                            id: "2",
                            title: "Renaissance",
                            rank: "2",
                            peak: "#1 (11x)",
                            weeks: "32",
                            streams: "15,200,000,000",
                            sales: "5,500,000",
                            units: "12,500,000",
                            certifications: [.diamond(count: 1), .platinum(count: 2)],
                            parent: MockChartEntry())
                    ],
                    .track: [
                        ChildChartEntryUIModel(
                            id: "1",
                            title: "Formation",
                            rank: "1",
                            peak: "#1 (2x)",
                            weeks: "12",
                            streams: "1,200,000,000",
                            sales: "1,300,000",
                            units: "1,500,000",
                            certifications: [.diamond(count: 1), .platinum(count: 2)],
                            parent: MockChartEntry()),
                        ChildChartEntryUIModel(
                            id: "2",
                            title: "Blow",
                            rank: "2",
                            peak: "#1 (2x)",
                            weeks: "12",
                            streams: "1,200,000,000",
                            sales: "1,300,000",
                            units: "1,500,000",
                            certifications: [.diamond(count: 1), .platinum(count: 2)],
                            parent: MockChartEntry())
                    ]
                ],
                parent: MockChartEntry())
        }
        // swiftlint:enable function_body_length
    }

    return NavigationView {
        ChartEntryDetailsScreen<MockViewModel>(
            entry: ArtistEntry(
                mbid: "",
                name: "Beyoncé",
                playCount: 12,
                rank: 1,
                week: WeekRange(from: 1708012800, to: 1708531200)),
            year: nil)
    }
}
// swiftlint:enable file_length
