//
//  UserUIModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/12/25.
//

import Foundation

struct UserUIModel {
    let name: String

    init(name: String) {
        self.name = name
    }

    init(user: User) {
        self.name = user.name
    }
}
