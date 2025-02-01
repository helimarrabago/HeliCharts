//
//  ChartMovementUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/12/25.
//

import SwiftUI

struct ChartMovementUIModel {
    let symbol: String
    let color: Color

    init(symbol: String, color: Color) {
        self.symbol = symbol
        self.color = color
    }

    init(movement: ChartMovement) {
        self.symbol = {
            switch movement {
            case .stay: return "="
            case .upwards(let value): return "↑\(value)"
            case .downward(let value): return "↓\(value)"
            case .reappear: return "RE"
            case .new: return "NEW"
            }
        }()
        self.color = {
            switch movement {
            case .stay: return .primary
            case .upwards: return .green
            case .downward: return .red
            case .reappear: return .yellow
            case .new: return .blue
            }
        }()
    }
}
