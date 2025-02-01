//
//  ArtistEntry.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

struct ArtistEntry: ChartEntry {
    typealias Repository = ArtistChartRepository

    let mbid: String
    let name: String
    let playCount: Int
    let rank: Int
    let week: WeekRange

    init(mbid: String, name: String, playCount: Int, rank: Int, week: WeekRange) {
        self.mbid = mbid
        self.name = name
        self.playCount = playCount
        self.rank = rank
        self.week = week
    }

    init(response: ArtistChartResponse.Metadata.Artist, week: WeekRange) {
        self.mbid = response.mbid
        self.name = response.name
        self.playCount = Int(response.playcount) ?? 999
        self.rank = Int(response.attributes.rank) ?? 999
        self.week = week
    }

    let artist: Artist? = nil
}

extension ArtistEntry: Identifiable {
    var id: String {
        if mbid.isEmpty {
            return name
        } else {
            return mbid
        }
    }
}

extension ArtistEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ArtistEntry, rhs: ArtistEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

extension ArtistEntry {
    func computeUnits(weeks: Int) -> ChartEntryUnits {
        let longevityBonus = 1 + 0.01 * log(Double(weeks) + 1)
        let rank = Double(rank); let maxRank = Double(Settings.albumChartLimit)
        let logRank = log(rank + 0.01); let logMaxRank = log(maxRank)
        let playCount = Double(playCount)

        var streams = (56 + 196 * (1 - (logRank / logMaxRank))) * 1_000_000
        streams = streams + pow(playCount, 1.4) * 1_000_000
        streams = streams * longevityBonus / 1_500

        var sales = (150 + 350 * (1 - (logRank / logMaxRank))) * 1_000
        sales = sales + pow(playCount, 1.2) * 3_000
        sales = sales * longevityBonus

        return ChartEntryUnits(
            streams: Int(streams),
            streamsEquivalent: Int(streams * 1_500),
            sales: Int(sales))
    }
}
