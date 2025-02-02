//
//  ChartEntry.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

protocol ChartEntry: Hashable {
    var id: String { get }
    var name: String { get }
    var artist: Artist? { get }
    var playCount: Int { get }
    var rank: Int { get }
    var week: WeekRange { get }

    static var streamConversionRate: Int { get }
    static func computeUnits(rank: Int, playCount: Int, weeks: Int) -> ChartEntryUnits<Self>
}

extension ChartEntry {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ChartEntry {
    func computeUnits(weeks: Int) -> ChartEntryUnits<Self> {
        return Self.computeUnits(rank: rank, playCount: playCount, weeks: weeks)
    }

    static func computeLongevityBonus(weeks: Int) -> Double {
        return 1 + 0.05 * log(Double(weeks) + 1)
    }
}

struct MockChartEntry: ChartEntry {
    let id: String = ""
    let name: String = ""
    let artist: Artist? = nil
    let playCount: Int = 0
    let rank: Int = 0
    let week: WeekRange = WeekRange(from: 1708012800, to: 1708531200)

    static var streamConversionRate: Int {
        return 0
    }

    static func computeUnits(rank: Int, playCount: Int, weeks: Int) -> ChartEntryUnits<Self> {
        return ChartEntryUnits(streams: 0, sales: 0)
    }

    static func == (lhs: MockChartEntry, rhs: MockChartEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
