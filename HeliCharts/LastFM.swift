//
//  LastFM.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

enum LastFM {
    static let baseURL = "ws.audioscrobbler.com"
    static let user = Credentials.username
    static let apiKey = Credentials.apiKey

    enum Method: String {
        case userInfo = "user.getinfo"
        case userWeeklyTrackChart = "user.getweeklytrackchart"
        case userWeeklyAlbumChart = "user.getweeklyalbumchart"
        case userWeeklyArtistChart = "user.getweeklyartistchart"
        case albumInfo = "album.getinfo"
    }

    typealias Params = [String: Any]
    static func createURL(method: Method, params: Params? = nil, limit: Int? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURL
        components.path = "/2.0/"

        var queryItems = [
            URLQueryItem(name: "method", value: method.rawValue),
            URLQueryItem(name: "user", value: user),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json")
        ]
        if let params = params {
            for param in params {
                let queryItem = URLQueryItem(name: param.key, value: String(describing: param.value))
                queryItems.append(queryItem)
            }
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        components.queryItems = queryItems

        return components.url
    }
}
