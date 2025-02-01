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

    func computeUnits(weeks: Int) -> ChartEntryUnits
}

extension ChartEntry {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MockChartEntry: ChartEntry {
    let id: String = ""
    let name: String = ""
    let artist: Artist? = nil
    let playCount: Int = 0
    let rank: Int = 0
    let week: WeekRange = WeekRange(from: 1708012800, to: 1708531200)

    func computeUnits(weeks: Int) -> ChartEntryUnits {
        return ChartEntryUnits(streams: 0, streamsEquivalent: 0, sales: 0)
    }

    static func == (lhs: MockChartEntry, rhs: MockChartEntry) -> Bool {
        return lhs.id == rhs.id
    }
}
