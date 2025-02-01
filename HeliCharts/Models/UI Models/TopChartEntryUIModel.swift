//
//  TopChartEntryUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

struct TopChartEntryUIModel: Identifiable {
    let id: String
    let title: String?
    let streams: String?
    let sales: String?
    let units: String?
    let weekNumber: String
    let week: String
    let type: ChartType
    let chart: any Chart

    init(
        id: String,
        title: String?,
        streams: String?,
        sales: String?,
        units: String?,
        weekNumber: String,
        week: String,
        type: ChartType,
        chart: some Chart
    ) {
        self.id = id
        self.title = title
        self.streams = streams
        self.sales = sales
        self.units = units
        self.weekNumber = weekNumber
        self.week = week
        self.type = type
        self.chart = chart
    }

    init(chart: some Chart) {
        let week = chart.week
        self.id = chart.id
        self.week = week.toLongFormat()
        self.type = chart.type
        self.chart = chart

        if let topEntry = chart.getTopEntry() {
            self.title = [topEntry.artist?.name, topEntry.name].compactMap { $0 }.joined(separator: " - ")

            let weeks: Int
            switch type {
            case .track:
                weeks = TrackChartRepository.getAppearancesSoFar(of: topEntry as! TrackEntry).count
            case .album:
                weeks = AlbumChartRepository.getAppearancesSoFar(of: topEntry as! AlbumEntry).count
            case .artist:
                weeks = ArtistChartRepository.getAppearancesSoFar(of: topEntry as! ArtistEntry).count
            }

            let (streams, sales, units) = topEntry.computeUnits(weeks: weeks)
            self.streams = streams.toDecimalFormat()
            self.sales = sales.toDecimalFormat()
            self.units = units.toDecimalFormat()
        } else {
            self.title = nil
            self.streams = nil
            self.sales = nil
            self.units = nil
        }

        let weekNumber: Int
        switch type {
        case .track:
            weekNumber = TrackChartRepository.getWeekNumber(of: week)
        case .album:
            weekNumber = AlbumChartRepository.getWeekNumber(of: week)
        case .artist:
            weekNumber = ArtistChartRepository.getWeekNumber(of: week)
        }
        self.weekNumber = String(weekNumber)
    }
}

extension TopChartEntryUIModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TopChartEntryUIModel, rhs: TopChartEntryUIModel) -> Bool {
        return lhs.id == rhs.id
    }
}
