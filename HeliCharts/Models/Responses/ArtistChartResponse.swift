//
//  ArtistChartResponse.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

struct ArtistChartResponse: Decodable {
    let weeklyartistchart: Metadata

    struct Metadata: Decodable {
        let artist: [Artist]
        let attr: Attributes

        enum CodingKeys: String, CodingKey {
            case artist
            case attr = "@attr"
        }

        struct Artist: Decodable {
            let mbid: String
            let name: String
            let playcount: String
            let attributes: Attributes

            enum CodingKeys: String, CodingKey {
                case mbid
                case name
                case playcount
                case attributes = "@attr"
            }

            struct Attributes: Decodable {
                let rank: String
            }
        }

        struct Attributes: Decodable {
            let from: String
            let to: String
        }
    }
}
