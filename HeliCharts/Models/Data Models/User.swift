//
//  User.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

struct User {
    let name: String
    let playCount: String
    let registeredDate: Int

    init(name: String, playCount: String, registeredDate: Int) {
        self.name = name
        self.playCount = playCount
        self.registeredDate = registeredDate
    }

    init(response: UserResponse) {
        self.name = response.user.name
        self.playCount = response.user.playcount
        self.registeredDate = response.user.registered.text
    }
}
