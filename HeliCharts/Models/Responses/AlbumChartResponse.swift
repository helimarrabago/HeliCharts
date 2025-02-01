//
//  AlbumChartResponse.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

// swiftlint:disable nesting
struct AlbumChartResponse: Decodable {
    let weeklyalbumchart: Metadata

    struct Metadata: Decodable {
        let album: [Album]
        let attr: Attributes

        enum CodingKeys: String, CodingKey {
            case album
            case attr = "@attr"
        }

        struct Album: Decodable {
            let mbid: String
            let name: String
            let artist: Artist
            let playcount: String
            let attr: Attributes

            enum CodingKeys: String, CodingKey {
                case mbid
                case name
                case artist
                case playcount
                case attr = "@attr"
            }

            struct Artist: Decodable {
                let mbid: String
                let text: String

                enum CodingKeys: String, CodingKey {
                    case mbid
                    case text = "#text"
                }
            }

            struct Attributes: Decodable {
                let rank: String
            }
        }

        struct Attributes: Decodable {
            let from: String
            let to: String // swiftlint:disable:this identifier_name
        }
    }
}
// swiftlint:enable nesting
