//
//  ChartEntryChildEntriesView.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/19/25.
//

import OrderedCollections
import SwiftUI

struct ChartEntryChildEntriesView: View {
    let entries: OrderedDictionary<ChartKind, [ChildChartEntryUIModel]>.Element
    let year: Int?

    var body: some View {
        List(entries.value) { entry in
            NavigationLink {
                ChartEntryDetailsView<ChartEntryDetailsViewModel>(entry: entry.parent, year: year)
            } label: {
                ChartEntryDetailedCell(entry: entry)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Top " + entries.key.objects)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ChartEntryChildEntriesView(
            entries: (
                key: .track,
                value: [
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
                ]),
            year: nil)
    }
}
