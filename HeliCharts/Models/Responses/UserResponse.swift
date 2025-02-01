//
//  UserResponse.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

struct UserResponse: Decodable {
    let user: User

    struct User: Decodable {
        let name: String
        let playcount: String
        let registered: Registered

        struct Registered: Decodable {
            let text: Int

            enum CodingKeys: String, CodingKey {
                case text = "#text"
            }
        }
    }
}
