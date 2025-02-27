//
//  WeeklyRecordUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/2/25.
//

import Foundation

struct WeeklyRecordUIModel {
    let name: String
    let rank: String
    let streams: String
    let sales: String
    let totalUnits: String
    let position: String
    let week: String

    init(
        name: String,
        rank: String,
        streams: String,
        sales: String,
        totalUnits: String,
        position: String,
        week: String
    ) {
        self.name = name
        self.rank = rank
        self.streams = streams
        self.sales = sales
        self.totalUnits = totalUnits
        self.position = position
        self.week = week
    }

    init(dataModel: WeeklyRecord) {
        self.name = dataModel.name
        self.rank = String(dataModel.rank)
        self.streams = dataModel.streams.toDecimalFormat()
        self.sales = dataModel.sales.toDecimalFormat()
        self.totalUnits = dataModel.totalUnits.toDecimalFormat()
        self.position = String(dataModel.position)

        var week = dataModel.week.toLongFormat()
        if let weekNumber = dataModel.weekNumber {
            week += " (\(weekNumber.toOrdinalFormat()) week)"
        }
        self.week = week
    }
}

extension WeeklyRecordUIModel: Identifiable {
    var id: String { return name + week }
}
