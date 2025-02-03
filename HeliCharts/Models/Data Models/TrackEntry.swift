//
//  TrackEntry.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

struct TrackEntry: ChartEntry {
    typealias Repository = TrackChartRepository

    let mbid: String
    let name: String
    let artist: Artist?
    let playCount: Int
    let rank: Int
    let week: WeekRange

    init(mbid: String, name: String, artist: Artist, playCount: Int, rank: Int, week: WeekRange) {
        self.mbid = mbid
        self.name = name
        self.artist = artist
        self.playCount = playCount
        self.rank = rank
        self.week = week
    }

    init(response: TrackChartResponse.Metadata.Track, week: WeekRange) {
        self.mbid = response.mbid
        self.name = response.name
        self.playCount = Int(response.playcount) ?? 999
        self.rank = Int(response.attr.rank) ?? 999
        self.week = week

        let artist = response.artist
        self.artist = Artist(id: artist.mbid, name: artist.text)
    }

    static var unitsCache: [WeekKey<TrackEntry>: ChartEntryUnits<TrackEntry>] = [:]
}

extension TrackEntry: Identifiable {
    var id: String {
        return artist!.name + " - " + name
    }
}

extension TrackEntry {
    static func == (lhs: TrackEntry, rhs: TrackEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

extension TrackEntry {
    static var streamConversionRate: Int {
        return 500
    }

    static func computeUnits(rank: Int, playCount: Int = 1, weeks: Int) -> ChartEntryUnits<Self> {
        let rank = Double(rank); let maxRank = Double(Settings.trackChartLimit)
        let logRank = log(rank + 0.01); let logMaxRank = log(maxRank)

        let playCount = Double(playCount)
        let longevityBonus = computeLongevityBonus(weeks: weeks)

        var streams = (14 + 49 * (1 - (logRank / logMaxRank))) * 1_000_000
        streams += pow(playCount, 1.4) * 1_000_000
        streams *= longevityBonus / Double(streamConversionRate)

        var sales = (50 + 150 * (1 - (logRank / logMaxRank))) * 1_000
        sales += pow(playCount, 1.2) * 3_000
        sales *= longevityBonus

        return ChartEntryUnits(streams: streams, sales: sales)
    }
}
