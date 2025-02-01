//
//  TrackChart.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

struct TrackChart: Chart {
    typealias EntryType = TrackEntry

    let entries: [TrackEntry]
    let week: WeekRange
    let kind: ChartKind = .track

    init(tracks: [TrackEntry], week: WeekRange) {
        self.entries = tracks
        self.week = week
    }

    init(response: TrackChartResponse) {
        let week = WeekRange(
            from: Int(response.weeklytrackchart.attr.from)!,
            to: Int(response.weeklytrackchart.attr.to)!)
        self.entries = response.weeklytrackchart.track.map { TrackEntry(response: $0, week: week) }
        self.week = week
    }
}

extension TrackChart: Identifiable {
    var id: String {
        return "\(week.from)-\(week.to)"
    }
}

extension TrackChart: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TrackChart, rhs: TrackChart) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TrackChart {
    func getTopEntry() -> TrackEntry? {
        let topTrack = entries.first(where: { $0.rank == 1 })
        return topTrack
    }

    func getSameEntry(as entry: TrackEntry) -> TrackEntry? {
        return entries.first { $0 == entry }
    }
}
