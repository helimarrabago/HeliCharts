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
    func computeUnits(weeks: Int) -> (streams: Int, sales: Int, units: Int) {
        let longevityBonus = 1 + 0.01 * log(Double(weeks) + 1)
        let rank = Double(rank); let maxRank = Double(Settings.trackChartLimit)
        let logRank = log(rank + 0.01); let logMaxRank = log(maxRank)
        let playCount = Double(playCount)

        var streams = (14 + 49 * (1 - (logRank / logMaxRank))) * 1_000_000
        streams = streams + pow(playCount, 1.4) * 1_000_000
        streams = streams * longevityBonus / 500

        var sales = (50 + 150 * (1 - (logRank / logMaxRank))) * 1_000
        sales = sales + pow(playCount, 1.2) * 3_000
        sales = sales * longevityBonus

        return (Int(streams * 500), Int(sales), Int(streams + sales))
    }
}
