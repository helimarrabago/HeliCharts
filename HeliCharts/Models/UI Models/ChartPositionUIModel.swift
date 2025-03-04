//
//  ChartPositionUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/12/25.
//

import Foundation

struct ChartPositionUIModel: Identifiable {
    let rank: String
    let units: String
    let runningUnits: String
    let date: String
    let weekNumber: String

    init(rank: String, units: String, runningUnits: String, date: String, weekNumber: String) {
        self.rank = rank
        self.units = units
        self.runningUnits = runningUnits
        self.date = date
        self.weekNumber = weekNumber
    }

    init(position: ChartPosition) {
        self.rank = "#\(position.rank)"
        self.units = position.totalUnits.toDecimalFormat()
        self.runningUnits = position.runningTotalUnits.toDecimalFormat()
        self.date = Date(timeIntervalSince1970: TimeInterval(position.week.to)).toFormat("MMM d, yyyy")
        self.weekNumber = String(position.weekNumber)
    }

    var id: String {
        return date
    }
}
