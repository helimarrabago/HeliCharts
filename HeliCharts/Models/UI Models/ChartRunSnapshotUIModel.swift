//
//  ChartRunSnapshotUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/12/25.
//

import Foundation

enum ChartRunSnapshotUIModel {
    case charted(position: ChartPositionUIModel)
    case outOfChart(count: String)

    init(snapshot: ChartRunSnapshot) {
        switch snapshot {
        case .charted(let position):
            self = .charted(position: ChartPositionUIModel(position: position))
        case .outOfChart(let count):
            self = .outOfChart(count: "\(count)x")
        }
    }
}

extension ChartRunSnapshotUIModel: Identifiable {
    var id: String {
        switch self {
        case .charted(let position): return position.id
        case .outOfChart: return UUID().uuidString
        }
    }
}

extension ChartRunSnapshotUIModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChartRunSnapshotUIModel, rhs: ChartRunSnapshotUIModel) -> Bool {
        return lhs.id == rhs.id
    }
}
