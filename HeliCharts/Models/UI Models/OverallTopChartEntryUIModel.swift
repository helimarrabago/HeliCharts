//
//  OverallTopChartEntryUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

struct OverallTopChartEntryUIModel: Identifiable {
    let id: String
    let trackTitle: String?
    let trackUnits: String?
    let albumTitle: String?
    let albumUnits: String?
    let artistTitle: String?
    let artistUnits: String?
    let weekNumber: String
    let week: String

    init(
        id: String,
        trackTitle: String,
        trackUnits: String,
        albumTitle: String,
        albumUnits: String,
        artistTitle: String,
        artistUnits: String,
        weekNumber: String,
        week: String
    ) {
        self.id = id
        self.trackTitle = trackTitle
        self.trackUnits = trackUnits
        self.albumTitle = albumTitle
        self.albumUnits = albumUnits
        self.artistTitle = artistTitle
        self.artistUnits = artistUnits
        self.weekNumber = weekNumber
        self.week = week
    }

    init(topTrack: TopChartEntryUIModel, topAlbum: TopChartEntryUIModel, topArtist: TopChartEntryUIModel) {
        self.id = [topTrack.id, topAlbum.id, topArtist.id].joined(separator: "&")
        self.trackTitle = topTrack.title
        self.trackUnits = topTrack.units
        self.albumTitle = topAlbum.title
        self.albumUnits = topAlbum.units
        self.artistTitle = topArtist.title
        self.artistUnits = topArtist.units
        self.weekNumber = topTrack.weekNumber
        self.week = topTrack.week
    }
}

extension OverallTopChartEntryUIModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OverallTopChartEntryUIModel, rhs: OverallTopChartEntryUIModel) -> Bool {
        return lhs.id == rhs.id
    }
}
