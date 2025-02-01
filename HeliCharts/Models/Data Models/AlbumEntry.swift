//
//  AlbumEntry.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

struct AlbumEntry: ChartEntry {
    typealias Repository = AlbumChartRepository

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

    init(response: AlbumChartResponse.Metadata.Album, week: WeekRange) {
        self.mbid = response.mbid
        self.name = response.name
        self.playCount = Int(response.playcount) ?? 999
        self.rank = Int(response.attr.rank) ?? 999
        self.week = week

        let artist = response.artist
        self.artist = Artist(id: artist.mbid, name: artist.text)
    }
}

extension AlbumEntry: Identifiable {
    var id: String {
        if mbid.isEmpty {
            return artist!.name + " - " + name
        } else {
            return mbid
        }
    }
}

extension AlbumEntry: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AlbumEntry, rhs: AlbumEntry) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AlbumEntry {
    static var streamConversionRate: Int {
        return 1_500
    }

    static func computeUnits(rank: Int, playCount: Int = 1, weeks: Int) -> ChartEntryUnits<Self> {
        let rank = Double(rank); let maxRank = Double(Settings.albumChartLimit)
        let logRank = log(rank + 0.01); let logMaxRank = log(maxRank)

        let playCount = Double(playCount)
        let longevityBonus = computeLongevityBonus(weeks: weeks)

        var streams = (28 + 98 * (1 - (logRank / logMaxRank))) * 1_000_000
        streams += pow(playCount, 1.4) * 1_000_000
        streams *= longevityBonus / Double(streamConversionRate)

        var sales = (75 + 200 * (1 - (logRank / logMaxRank))) * 1_000
        sales += pow(playCount, 1.2) * 3_000
        sales *= longevityBonus

        return ChartEntryUnits(streams: Int(streams), sales: Int(sales))
    }
}
