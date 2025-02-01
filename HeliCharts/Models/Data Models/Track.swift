//
//  Track.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/20/25.
//

import Foundation

struct Track {
    let name: String

    init(name: String) {
        self.name = name
    }

    init(response: AlbumResponse.Metadata.TrackMetadata.Track) {
        self.name = response.name
    }
}
