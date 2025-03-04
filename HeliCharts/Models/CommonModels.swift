//
//  CommonModels.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import OrderedCollections
import SwiftUI

struct WeekRange: Hashable {
    let from: Int
    let to: Int // swiftlint:disable:this identifier_name
}

enum ChartKind: CaseIterable, Hashable {
    case track
    case album
    case artist

    var title: String {
        switch self {
        case .track: return "Top \(Settings.trackChartLimit) \(objects)"
        case .album: return "Top \(Settings.albumChartLimit) \(objects)"
        case .artist: return "Top \(Settings.artistChartLimit) \(objects)"
        }
    }

    var objects: String {
        switch self {
        case .track: return "Tracks"
        case .album: return "Albums"
        case .artist: return "Artists"
        }
    }

    var emoji: String {
        switch self {
        case .track: return "🎶"
        case .album: return "💿"
        case .artist: return "🎤"
        }
    }

    var image: Image {
        switch self {
        case .track: return Image(systemName: "music.note")
        case .album: return Image(systemName: "opticaldisc.fill")
        case .artist: return Image(systemName: "person.fill")
        }
    }
}

enum TopChartKind: CaseIterable {
    case track
    case album
    case artist
    case overall

    var image: Image {
        switch self {
        case .track: return Image(systemName: "music.note")
        case .album: return Image(systemName: "opticaldisc.fill")
        case .artist: return Image(systemName: "person.fill")
        case .overall: return Image(systemName: "chart.bar.doc.horizontal.fill")
        }
    }
}

enum ChartMetric: CaseIterable, Hashable {
    case totalUnits
    case streams
    case sales

    var name: String {
        switch self {
        case .totalUnits: return "Total Units"
        case .streams: return "Streams"
        case .sales: return "Sales"
        }
    }
}

struct ChartEntrySnapshotHistory {
    let movement: ChartMovement
    let peak: Int
    let weeksOnPeak: Int
    let weeksOnChart: Int
}

enum ChartMovement {
    case stay
    case upwards(value: Int)
    case downward(value: Int)
    case reappear
    case new
}

struct ChartOverallHistory {
    let parent: any ChartEntry
    let peak: Int
    let weeksOnPeak: Int
    let weeksOnChart: Int
    let streams: Int
    let sales: Int
    let totalUnits: Int
    let certifications: [Certification]?
    let chartRun: [ChartRunSnapshot]
    let childEntries: OrderedDictionary<ChartKind, [ChildChartEntry]>?
}

enum Certification: Hashable {
    case gold(count: Int)
    case platinum(count: Int)
    case diamond(count: Int)

    var icon: Image {
        switch self {
        case .gold: return Image(.goldRecord)
        case .platinum: return Image(.platinumRecord)
        case .diamond: return Image(.diamondRecord)
        }
    }

    var formatted: String {
        switch self {
        case .gold(let count): return "\(count)x Gold"
        case .platinum(let count): return "\(count)x Platinum"
        case .diamond(let count): return "\(count)x Diamond"
        }
    }
}

enum ChartRunSnapshot {
    case charted(position: ChartPosition)
    case outOfChart(count: Int)

    var position: ChartPosition? {
        guard case .charted(let position) = self else { return nil }
        return position
    }
}

struct ChartPosition {
    let rank: Int
    let streams: Int
    let sales: Int
    let totalUnits: Int
    let runningStreams: Int
    let runningSales: Int
    let runningTotalUnits: Int
    let week: WeekRange
    let weekNumber: Int
}

struct ChildChartEntry {
    let id: String
    let name: String
    let aggregate: ChartEntryAggregate
}

struct YearEndChartEntry {
    let id: String
    let name: String
    let artist: Artist?
    let movement: ChartMovement
    let aggregate: ChartEntryAggregate
}

struct AllTimeChartEntry {
    let id: String
    let name: String
    let artist: Artist?
    let aggregate: ChartEntryAggregate
}

struct ChartEntryAggregate {
    let parent: any ChartEntry
    let rank: Int
    let peak: Int
    let weeksOnPeak: Int
    let weeksOnChart: Int
    let streams: Int
    let sales: Int
    let totalUnits: Int
    let certifications: [Certification]?
}

struct ChartEntryUnits<ChartEntryType: ChartEntry> {
    let rawStreams: Double
    let rawSales: Double

    init(streams: Double, sales: Double) {
        self.rawStreams = streams
        self.rawSales = sales
    }

    var streams: Int { return Int(rawStreams) }
    var sales: Int { return Int(rawSales) }
    var streamsEquivalent: Int { return Int(rawStreams * Double(ChartEntryType.streamConversionRate)) }
    var total: Int { return Int(rawStreams + rawSales) }
}

enum WeeklyRecordType {
    case mostWeeklyUnits
    case biggestDebuts
    case biggestPeaks
}

struct WeeklyRecord {
    let name: String
    let rank: Int
    let streams: Int
    let sales: Int
    let totalUnits: Int
    let position: Int
    let week: WeekRange
    let weekNumber: Int?
}

enum FastestRecordType {
    case milestoneUnits
}

enum FastestRecordMilestone: Hashable {
    case units(metric: ChartMetric, value: Int)

    var displayName: String {
        switch self {
        case .units(_, let value):
            return value.toDecimalFormat()
        }
    }
}

struct FastestRecord {
    let name: String
    let rank: Int
    let streams: Int
    let sales: Int
    let units: Int
    let runningUnits: Int
    let week: WeekRange
    let weekCount: Int
}
