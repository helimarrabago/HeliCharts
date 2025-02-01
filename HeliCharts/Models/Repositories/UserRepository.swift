//
//  UserRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/13/25.
//

import Combine
import Foundation

enum UserRepository {
    static var user = CurrentValueSubject<User?, Never>(nil)
}
