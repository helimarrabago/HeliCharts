//
//  FastestRecordUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 3/1/25.
//

import Foundation

struct FastestRecordUIModel {
    let name: String
    let rank: String
    let streams: String
    let sales: String
    let runningUnits: String
    let week: String
    let weekCount: String

    init(
        name: String,
        rank: String,
        streams: String,
        sales: String,
        runningUnits: String,
        week: String,
        weekCount: String
    ) {
        self.name = name
        self.rank = rank
        self.streams = streams
        self.sales = sales
        self.runningUnits = runningUnits
        self.week = week
        self.weekCount = weekCount
    }

    init(dataModel: FastestRecord) {
        self.name = dataModel.name
        self.rank = String(dataModel.rank)
        self.streams = "+\(dataModel.streams.toDecimalFormat())"
        self.sales = "+\(dataModel.sales.toDecimalFormat())"
        self.week = dataModel.week.toLongFormat()
        self.weekCount = String(dataModel.weekCount)

        let runningUnits = dataModel.runningUnits
        let previousUnits = runningUnits - dataModel.units
        self.runningUnits = "\(previousUnits.toDecimalFormat()) → \(runningUnits.toDecimalFormat())"
    }
}

extension FastestRecordUIModel: Identifiable {
    var id: String { return name + week }
}
