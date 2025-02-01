//
//  ChartEntryDetailsUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation
import OrderedCollections

struct ChartEntryDetailsUIModel {
    let id: String
    let name: String
    let artist: Artist?
    let streams: String
    let sales: String
    let totalUnits: String
    let weeks: String
    let peak: String
    let certifications: [Certification]?
    let chartRun: [ChartRunSnapshotUIModel]
    let childEntries: OrderedDictionary<ChartType, [ChildChartEntryUIModel]>?
    let parent: any ChartEntry

    var artistName: String? {
        return artist?.name
    }

    init(
        id: String,
        name: String,
        artist: Artist?,
        streams: String,
        sales: String,
        totalUnits: String,
        weeks: String,
        peak: String,
        certifications: [Certification]?,
        chartRun: [ChartRunSnapshotUIModel],
        childEntries: OrderedDictionary<ChartType, [ChildChartEntryUIModel]>?,
        parent: any ChartEntry
    ) {
        self.id = id
        self.name = name
        self.artist = artist
        self.streams = streams
        self.sales = sales
        self.totalUnits = totalUnits
        self.weeks = weeks
        self.peak = peak
        self.certifications = certifications
        self.chartRun = chartRun
        self.childEntries = childEntries
        self.parent = parent
    }

    init(entry: any ChartEntry, year: Int?) {
        self.id = entry.id
        self.name = entry.name
        self.artist = entry.artist
        self.parent = entry

        let history = {
            if let track = entry as? TrackEntry {
                return TrackChartRepository.getOverallHistory(of: track, year: year)
            } else if let album = entry as? AlbumEntry {
                return AlbumChartRepository.getOverallHistory(of: album, year: year)
            } else {
                let artist = entry as! ArtistEntry
                return ArtistChartRepository.getOverallHistory(of: artist, year: year)
            }
        }()

        self.streams = history.streams.toShortFormat()
        self.sales = history.sales.toShortFormat()
        self.totalUnits = history.totalUnits.toDecimalFormat()
        self.weeks = String(history.weeksOnChart)
        self.peak = "#\(history.peakRank) (\(history.weeksOnPeak)x)"
        self.certifications = history.certifications
        self.chartRun = history.chartRun.map { ChartRunSnapshotUIModel(snapshot: $0) }

        if let entries = history.childEntries {
            var childEntries: OrderedDictionary<ChartType, [ChildChartEntryUIModel]> = [:]
            for (chartType, entries) in entries {
                guard !entries.isEmpty else { continue }
                childEntries[chartType] = entries.map { ChildChartEntryUIModel(entry: $0) }
            }
            self.childEntries = childEntries
        } else {
            self.childEntries = nil
        }
    }
}
