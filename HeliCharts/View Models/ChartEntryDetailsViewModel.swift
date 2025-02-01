//
//  ChartEntryDetailsViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Foundation

protocol ChartEntryDetailsViewModelProtocol: ObservableObject {
    init()
    func fetchAlbum(from entry: any ChartEntry) async throws
    func generateDetails(of entry: any ChartEntry, year: Int?) async -> ChartEntryDetailsUIModel
}

final class ChartEntryDetailsViewModel: ChartEntryDetailsViewModelProtocol {
    func fetchAlbum(from entry: any ChartEntry) async throws {
        guard let albumEntry = entry as? AlbumEntry else { return }

        let name = albumEntry.name
        let artist = albumEntry.artist!.name
        let key = AlbumKey(name: name, artist: artist)

        guard AlbumRepository.albums[key] == nil else { return }

        let url = LastFM.createURL(
            method: .albumInfo,
            params: ["artist": artist, "album": name],
            limit: Settings.artistChartLimit)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AlbumResponse.self, from: data)

        let album = Album(response: response.album)
        AlbumRepository.albums[key] = album
    }

    func generateDetails(of entry: any ChartEntry, year: Int?) async -> ChartEntryDetailsUIModel {
        return ChartEntryDetailsUIModel(entry: entry, year: year)
    }
}
