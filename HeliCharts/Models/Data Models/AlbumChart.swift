//
//  AlbumChart.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

struct AlbumChart: Chart {
    typealias EntryType = AlbumEntry

    let entries: [AlbumEntry]
    let week: WeekRange
    let kind: ChartKind = .album

    init(albums: [AlbumEntry], week: WeekRange) {
        self.entries = albums
        self.week = week
    }

    init(response: AlbumChartResponse) {
        let week = WeekRange(
            from: Int(response.weeklyalbumchart.attr.from)!,
            to: Int(response.weeklyalbumchart.attr.to)!)
        self.entries = response.weeklyalbumchart.album.map { AlbumEntry(response: $0, week: week) }
        self.week = week
    }
}

extension AlbumChart: Identifiable {
    var id: String {
        return "\(week.from)-\(week.to)"
    }
}

extension AlbumChart: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AlbumChart, rhs: AlbumChart) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AlbumChart {
    func getTopEntry() -> AlbumEntry? {
        let topTrack = entries.first(where: { $0.rank == 1 })
        return topTrack
    }

    func getSameEntry(as entry: AlbumEntry) -> AlbumEntry? {
        return entries.first { $0 == entry }
    }
}
