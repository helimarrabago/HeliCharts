//
//  Chart.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

protocol Chart {
    associatedtype Entry: ChartEntry

    var id: String { get }
    var entries: [Entry] { get }
    var week: WeekRange { get }
    var kind: ChartKind { get }

    func getTopEntry() -> Entry?
    func getSameEntry(as entry: Entry) -> Entry?
}

struct MockChart: Chart {
    typealias Entry = TrackEntry
    let id: String = ""
    let week: WeekRange = WeekRange(from: 1708012800, to: 1708531200)
    let kind: ChartKind = .track
    let entries: [TrackEntry] = []

    func getTopEntry() -> TrackEntry? { return nil }
    func getSameEntry(as entry: TrackEntry) -> TrackEntry? { return nil }
}
