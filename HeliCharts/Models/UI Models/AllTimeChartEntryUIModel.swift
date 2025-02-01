//
//  AllTimeChartEntryUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/21/25.
//

import Foundation

struct AllTimeChartEntryUIModel: Identifiable {
    let id: String
    let title: String
    let rank: String
    let peak: String
    let weeks: String
    let streams: String
    let sales: String
    let units: String
    let certifications: [Certification]?
    let parent: any ChartEntry

    init(
        id: String,
        title: String,
        rank: String,
        peak: String,
        weeks: String,
        streams: String,
        sales: String,
        units: String,
        certifications: [Certification]?,
        parent: some ChartEntry
    ) {
        self.id = id
        self.title = title
        self.rank = rank
        self.peak = peak
        self.weeks = weeks
        self.streams = streams
        self.sales = sales
        self.units = units
        self.certifications = certifications
        self.parent = parent
    }

    init(entry: AllTimeChartEntry) {
        self.id = entry.id
        self.title = [entry.artist?.name, entry.name].compactMap { $0 }.joined(separator: " - ")

        let aggregate = entry.aggregate
        self.rank = String(aggregate.rank)
        self.peak = "#\(aggregate.peak) (\(aggregate.weeksOnPeak)x)"
        self.weeks = String(aggregate.weeksOnChart)
        self.streams = aggregate.streams.toDecimalFormat()
        self.sales = aggregate.sales.toDecimalFormat()
        self.units = aggregate.totalUnits.toDecimalFormat()
        self.certifications = aggregate.certifications
        self.parent = aggregate.parent
    }
}
