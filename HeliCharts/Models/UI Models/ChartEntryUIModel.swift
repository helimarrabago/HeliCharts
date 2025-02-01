//
//  ChartEntryUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

struct ChartEntryUIModel: Identifiable {
    let id: String
    let rank: String
    let movement: ChartMovementUIModel
    let title: String
    let streams: String
    let sales: String
    let units: String
    let peak: String
    let weeks: String
    let parent: any ChartEntry

    init(
        id: String,
        rank: String,
        movement: ChartMovementUIModel,
        title: String,
        streams: String,
        sales: String,
        units: String,
        peak: String,
        weeks: String,
        parent: some ChartEntry
    ) {
        self.id = id
        self.rank = rank
        self.movement = movement
        self.title = title
        self.streams = streams
        self.sales = sales
        self.units = units
        self.peak = peak
        self.weeks = weeks
        self.parent = parent
    }

    init(entry: some ChartEntry) {
        self.id = entry.id
        self.rank = String(entry.rank)
        self.title = [entry.artist?.name, entry.name].compactMap { $0 }.joined(separator: " - ")
        self.parent = entry

        let history = {
            if let track = entry as? TrackEntry {
                return TrackChartRepository.getSnapshotHistory(of: track)
            } else if let album = entry as? AlbumEntry {
                return AlbumChartRepository.getSnapshotHistory(of: album)
            } else if let artist = entry as? ArtistEntry {
                return ArtistChartRepository.getSnapshotHistory(of: artist)
            } else {
                fatalError("Use a known ChartEntry type.")
            }
        }()

        self.movement = ChartMovementUIModel(movement: history.movement)
        self.peak = "#\(history.peakRank) (\(history.weeksOnPeak)x)"
        self.weeks = String(history.weeksOnChart)

        let units = entry.computeUnits(weeks: history.weeksOnChart)
        self.streams = units.streamsEquivalent.toDecimalFormat()
        self.sales = units.sales.toDecimalFormat()
        self.units = units.total.toDecimalFormat()
    }
}
