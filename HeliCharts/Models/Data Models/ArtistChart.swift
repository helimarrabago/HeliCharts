//
//  ArtistChart.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

struct ArtistChart: Chart {
    typealias EntryType = ArtistEntry

    let entries: [ArtistEntry]
    let week: WeekRange
    let type: ChartType = .artist

    init(artists: [ArtistEntry], week: WeekRange) {
        self.entries = artists
        self.week = week
    }

    init(response: ArtistChartResponse) {
        let week = WeekRange(
            from: Int(response.weeklyartistchart.attr.from)!,
            to: Int(response.weeklyartistchart.attr.to)!)
        self.entries = response.weeklyartistchart.artist.map { ArtistEntry(response: $0, week: week) }
        self.week = week
    }
}

extension ArtistChart: Identifiable {
    var id: String {
        return "\(week.from)-\(week.to)"
    }
}

extension ArtistChart: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ArtistChart, rhs: ArtistChart) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ArtistChart {
    func getTopEntry() -> ArtistEntry? {
        let topArtist = entries.first(where: { $0.rank == 1 })
        return topArtist
    }

    func getSameEntry(as entry: ArtistEntry) -> ArtistEntry? {
        return entries.first { $0 == entry }
    }
}
