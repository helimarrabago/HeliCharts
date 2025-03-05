//
//  FastestRecordViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 3/1/25.
//

import Foundation

protocol FastestRecordViewModelProtocol: ObservableObject {
    func fetchFastestTrackRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel]
    func fetchFastestAlbumRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel]
    func fetchFastestArtistRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel]
}

final class FastestRecordViewModel: FastestRecordViewModelProtocol {
    func fetchFastestTrackRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel] {
        let fastestRecord: [FastestRecord]
        switch (type, milestone) {
        case (.milestoneUnits, .units(let metric, let value)):
            fastestRecord = TrackChartRepository.generateFastestMilestoneUnits(metric: metric, value: value)
        }

        return fastestRecord.map { FastestRecordUIModel(dataModel: $0) }
    }

    func fetchFastestAlbumRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel] {
        let fastestRecord: [FastestRecord]
        switch (type, milestone) {
        case (.milestoneUnits, .units(let metric, let value)):
            fastestRecord = AlbumChartRepository.generateFastestMilestoneUnits(metric: metric, value: value)
        }

        return fastestRecord.map { FastestRecordUIModel(dataModel: $0) }
    }

    func fetchFastestArtistRecord(type: FastestRecordType, milestone: FastestRecordMilestone) async -> [FastestRecordUIModel] {
        let fastestRecord: [FastestRecord]
        switch (type, milestone) {
        case (.milestoneUnits, .units(let metric, let value)):
            fastestRecord = ArtistChartRepository.generateFastestMilestoneUnits(metric: metric, value: value)
        }

        return fastestRecord.map { FastestRecordUIModel(dataModel: $0) }
    }
}
