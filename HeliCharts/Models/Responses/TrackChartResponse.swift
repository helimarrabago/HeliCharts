//
//  TrackChartResponse.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/9/25.
//

import Foundation

// swiftlint:disable nesting
struct TrackChartResponse: Decodable {
    let weeklytrackchart: Metadata

    struct Metadata: Decodable {
        let track: [Track]
        let attr: Attributes

        enum CodingKeys: String, CodingKey {
            case track
            case attr = "@attr"
        }

        struct Track: Decodable {
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
