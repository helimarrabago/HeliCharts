//
//  MostWeeklyUnitsUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/2/25.
//

import Foundation

struct MostWeeklyUnitsUIModel {
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

    init(dataModel: MostWeeklyUnits) {
        self.name = dataModel.name
        self.rank = String(dataModel.rank)
        self.streams = dataModel.streams.toDecimalFormat()
        self.sales = dataModel.sales.toDecimalFormat()
        self.totalUnits = dataModel.totalUnits.toDecimalFormat()
        self.position = String(dataModel.position)
        self.week = dataModel.week.toLongFormat()
    }
}

extension MostWeeklyUnitsUIModel: Identifiable {
    var id: String { return name + week }
}
