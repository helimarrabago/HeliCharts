//
//  ChartRepository.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/11/25.
//

import Combine
import Foundation
import OrderedCollections

protocol ChartRepository<ChartKind> {
    associatedtype ChartKind: Chart
    typealias ChartEntryKind = ChartKind.Entry

    static var allCharts: CurrentValueSubject<[ChartKind], Never> { get set }
    static var snapshotHistoryCache: [SnapshotHistoryKey<ChartEntryKind>: ChartSnapshotHistory] { get set }
    static var overallHistoryCache: [OverallHistoryKey<ChartEntryKind>: ChartOverallHistory] { get set }
    static var yearEndChartCache: [YearEndChartKey: [YearEndChartEntry]] { get set }
    static var allTimeChartCache: [ChartMetric: [AllTimeChartEntry]] { get set }
}

// MARK: - Entry-specific Methods
extension ChartRepository {
    static func getIndex(of week: WeekRange) -> Int? {
        return allCharts.value.firstIndex { $0.week == week }
    }

    static func getWeekNumber(of week: WeekRange) -> Int {
        return allCharts.value.count - getIndex(of: week)!
    }

    static func getSnapshotHistory(of entry: ChartEntryKind) -> ChartSnapshotHistory {
        let key = SnapshotHistoryKey(entry: entry, week: entry.week)
        if let history = snapshotHistoryCache[key] {
            return history
        }

        let appearancesSoFar = getAppearancesSoFar(of: entry)
        guard appearancesSoFar.count > 1 else {
            // Newly charted
            let history = ChartSnapshotHistory(movement: .new, peakRank: entry.rank, weeksOnPeak: 1, weeksOnChart: 1)
            snapshotHistoryCache[key] = history
            return history
        }

        let peakRank = getPeakRank(among: appearancesSoFar)
        let history = ChartSnapshotHistory(
            movement: getMovement(of: entry, from: appearancesSoFar),
            peakRank: peakRank,
            weeksOnPeak: getWeeks(onPeak: peakRank, among: appearancesSoFar),
            weeksOnChart: appearancesSoFar.count)
        snapshotHistoryCache[key] = history

        return history
    }

    static func getOverallHistory(of entry: ChartEntryKind, year: Int?) -> ChartOverallHistory {
        let key = OverallHistoryKey(entry: entry, year: year)
        if let history = overallHistoryCache[key] {
            return history
        }

        let allAppearances = getAllAppearances(of: entry, year: year)
        let childEntries = getChildEntries(of: entry, year: year)

        guard allAppearances.count > 1 else {
            // Newly charted
            let (streams, sales, units) = entry.computeUnits(weeks: 1)
            let certifications = getCertifications(for: entry, totalUnits: units)
            let position = ChartPosition(
                rank: entry.rank,
                units: units,
                runningUnits: units,
                date: Date(timeIntervalSince1970: TimeInterval(entry.week.from)),
                weekNumber: getWeekNumber(of: entry.week))

            let history = ChartOverallHistory(
                peakRank: entry.rank,
                weeksOnPeak: 1,
                weeksOnChart: 1,
                streams: streams,
                sales: sales,
                totalUnits: units,
                certifications: certifications,
                chartRun: [.charted(position: position)],
                childEntries: childEntries)
            overallHistoryCache[key] = history

            return history
        }

        let peakRank = getPeakRank(among: allAppearances)
        let (streams, sales, totalUnits) = getTotalUnits(among: allAppearances)
        let certifications = getCertifications(for: entry, totalUnits: totalUnits)

        let history = ChartOverallHistory(
            peakRank: peakRank,
            weeksOnPeak: getWeeks(onPeak: peakRank, among: allAppearances),
            weeksOnChart: allAppearances.count,
            streams: streams,
            sales: sales,
            totalUnits: totalUnits,
            certifications: certifications,
            chartRun: getChartRun(of: entry, year: year),
            childEntries: childEntries)
        overallHistoryCache[key] = history

        return history
    }

    static func getAppearancesSoFar(of entry: ChartEntryKind) -> [ChartEntryKind] {
        guard allCharts.value.count > 1, let weekIndex = getIndex(of: entry.week) else {
            return [entry]
        }

        let chartsSoFar = Array(allCharts.value.suffix(from: weekIndex))
        let appearancesSoFar = chartsSoFar.compactMap { $0.getSameEntry(as: entry) }

        return appearancesSoFar
    }
}

private extension ChartRepository {
    static func getAllAppearances(of entry: ChartEntryKind, year: Int?) -> [ChartEntryKind] {
        let charts: [ChartKind]
        if let year = year {
            charts = getCharts(in: year)
        } else {
            charts = allCharts.value
        }

        guard charts.count > 1 else {
            return [entry]
        }

        let allAppearances = charts.compactMap { $0.getSameEntry(as: entry) }
        return allAppearances
    }

    static func getMovement(of entry: ChartEntryKind, from appearancesSoFar: [ChartEntryKind]) -> ChartMovement {
        let previousAppearance = appearancesSoFar[1]
        guard previousAppearance.week.isImmediatelyBefore(week: entry.week) else {
            return .reappear // Re-appeared
        }

        let previousRank = previousAppearance.rank
        let movement = previousRank - entry.rank

        if movement > 0 {
            return .upwards(value: movement) // Climbed up
        } else if movement < 0 {
            return .downward(value: abs(movement)) // Fell down
        } else {
            return .stay // Remained
        }
    }

    static func getPeakRank(among appearances: [ChartEntryKind]) -> Int {
        let allRanks = appearances.map { $0.rank }
        return allRanks.min() ?? 0
    }

    static func getWeeks(onPeak peak: Int, among appearances: [ChartEntryKind]) -> Int {
        let weeksOnPeak = appearances.filter { $0.rank == peak }.count
        return weeksOnPeak
    }

    static func getTotalUnits(among appearances: [ChartEntryKind]) -> (streams: Int, sales: Int, units: Int) {
        let totalUnits = appearances.enumerated()
            .map { $1.computeUnits(weeks: $0 + 1) }
            .reduce(into: (streams: 0, sales: 0, units: 0)) { partialUnits, units in
                partialUnits = (
                    partialUnits.streams + units.streams,
                    partialUnits.sales + units.sales,
                    partialUnits.units + units.units)
            }
        return totalUnits
    }

    static func getCertifications(for entry: any ChartEntry, totalUnits: Int) -> [Certification]? {
        guard !(entry is ArtistEntry) else { return nil }

        let diamondUnits = 10_000_000
        let platinumUnits = 1_000_000
        let goldUnits = 500_000

        var remainingUnits = totalUnits

        let diamondCount = remainingUnits / diamondUnits
        remainingUnits %= diamondUnits

        let platinumCount = remainingUnits / platinumUnits
        remainingUnits %= platinumUnits

        let goldCount = (diamondCount == 0 && platinumCount == 0) ? remainingUnits / goldUnits : 0

        var certifications: [Certification] = []
        if diamondCount > 0 {
            certifications.append(.diamond(count: diamondCount))
        }
        if platinumCount > 0 {
            certifications.append(.platinum(count: platinumCount))
        }
        if goldCount > 0 {
            certifications.append(.gold(count: goldCount))
        }

        guard !certifications.isEmpty else { return nil }
        return certifications
    }

    static func getChartRun(of entry: ChartEntryKind, year: Int?) -> [ChartRunSnapshot] {
        var chartRun: [ChartRunSnapshot] = []
        var runningUnits = 0

        // Get all charts from the first appearance to the last
        var allAppearances = Array(allCharts.value.reversed())
        guard
            let firstAppearance = allAppearances.firstIndex(where: { chart in
                let hasSameEntry = chart.getSameEntry(as: entry) != nil
                if let year = year {
                    return hasSameEntry && chart.week.isInYear(year)
                }
                return hasSameEntry
            }),
            let lastAppearance = allAppearances.lastIndex(where: { chart in
                let hasSameEntry = chart.getSameEntry(as: entry) != nil
                if let year = year {
                    return hasSameEntry && chart.week.isInYear(year)
                }
                return hasSameEntry
            })
        else {
            return []
        }
        allAppearances = Array(allAppearances[firstAppearance...lastAppearance])

        var outOfChartCount = 0
        var weeks = 0
        allAppearances.forEach { chart in
            if let entry = chart.getSameEntry(as: entry) {
                weeks += 1

                if outOfChartCount > 0 {
                    chartRun.append(.outOfChart(count: outOfChartCount))
                    outOfChartCount = 0
                }

                let units = entry.computeUnits(weeks: weeks).units
                runningUnits += units
                let position = ChartPosition(
                    rank: entry.rank,
                    units: units,
                    runningUnits: runningUnits,
                    date: Date(timeIntervalSince1970: TimeInterval(chart.week.to)),
                    weekNumber: getWeekNumber(of: chart.week))

                chartRun.append(.charted(position: position))
            } else {
                outOfChartCount += 1
            }
        }

        return chartRun
    }

    static func getChildEntries(
        of entry: ChartEntryKind,
        year: Int?
    ) -> OrderedDictionary<ChartType, [ChildChartEntry]>? {
        let childEntries: OrderedDictionary<ChartType, [any ChartEntry]>
        if entry is ArtistEntry {
            var albumCharts = AlbumChartRepository.allCharts.value
            var trackCharts = TrackChartRepository.allCharts.value
            if let year = year {
                albumCharts = albumCharts.filter { $0.week.isInYear(year) }
                trackCharts = trackCharts.filter { $0.week.isInYear(year) }
            }

            let childAlbums = albumCharts
                .flatMap { $0.entries }
                .filter { $0.artist?.name.lowercased() == entry.name.lowercased() }
            let childTracks = trackCharts
                .flatMap { $0.entries }
                .filter { $0.artist?.name.lowercased() == entry.name.lowercased() }
            childEntries = [.album: childAlbums, .track: childTracks]
        } else if entry is AlbumEntry {
            let key = AlbumKey(name: entry.name, artist: entry.artist!.name)
            guard let album = AlbumRepository.albums[key] else { return nil }

            var trackCharts = TrackChartRepository.allCharts.value
            if let year = year {
                trackCharts = trackCharts.filter { $0.week.isInYear(year) }
            }

            let tracks = album.tracks
            let childTracks = trackCharts.flatMap { $0.entries }.filter { track in
                return entry.artist?.name.lowercased() == track.artist?.name.lowercased() &&
                       tracks.contains { $0.name.lowercased() == track.name.lowercased() }
            }
            childEntries = [.track: childTracks]
        } else {
            return nil
        }

        var rankedChildEntries: OrderedDictionary<ChartType, [ChildChartEntry]> = [:]
        for (chartType, entries) in childEntries {
            let aggregates = aggregateEntries(entries, by: .totalUnits)
            rankedChildEntries[chartType] = aggregates.map { aggregate in
                return ChildChartEntry(
                    id: aggregate.parent.id,
                    name: aggregate.parent.name,
                    aggregate: aggregate)
            }
        }

        return rankedChildEntries
    }
}

// MARK: - Overall Methods
extension ChartRepository {
    static func generateYearEndChart(for year: Int, metric: ChartMetric) -> [YearEndChartEntry] {
        let key = YearEndChartKey(year: year, metric: metric)
        if let chart = yearEndChartCache[key] {
            return chart
        }

        let entries = getCharts(in: year).flatMap { $0.entries }
        guard !entries.isEmpty else { return [] }

        let lastYearEndChart = generateYearEndChart(for: year - 1, metric: metric)
        let aggregates = aggregateEntries(entries, by: metric, count: 100)
        let topEntries = aggregates.map { aggregate in
            let lastYearEntry = lastYearEndChart.first { $0.id == aggregate.parent.id }
            let movement: ChartMovement = {
                guard let previousRank = lastYearEntry?.aggregate.rank else { return .new }
                let movement = previousRank - aggregate.rank

                if movement > 0 {
                    return .upwards(value: movement) // Climbed up
                } else if movement < 0 {
                    return .downward(value: abs(movement)) // Fell down
                } else {
                    return .stay // Remained
                }
            }()

            return YearEndChartEntry(
                id: aggregate.parent.id,
                name: aggregate.parent.name,
                artist: aggregate.parent.artist,
                movement: movement,
                aggregate: aggregate)
        }

        yearEndChartCache[key] = topEntries
        return topEntries
    }

    static func generateAllTimeChart(metric: ChartMetric) -> [AllTimeChartEntry] {
        if let chart = allTimeChartCache[metric] {
            return chart
        }

        let entries = allCharts.value.flatMap { $0.entries }
        let aggregates = aggregateEntries(entries, by: metric, count: 100)
        let topEntries = aggregates.map { aggregate in
            return AllTimeChartEntry(
                id: aggregate.parent.id,
                name: aggregate.parent.name,
                artist: aggregate.parent.artist,
                aggregate: aggregate)
        }

        allTimeChartCache[metric] = topEntries
        return topEntries
    }
}

private extension ChartRepository {
    static func getCharts(in year: Int) -> [ChartKind] {
        let yearlyCharts = allCharts.value.filter { $0.week.isInYear(year) }
        return yearlyCharts
    }

    static func aggregateEntries(
        _ entries: [any ChartEntry],
        by metric: ChartMetric,
        count: Int? = nil
    ) -> [ChartEntryAggregate] {
        var rawAggregates: [String: ChartEntryAggregate] = [:]

        for entry in entries {
            let id = entry.id

            if let existing = rawAggregates[id] {
                let weeksOnChart = existing.weeksOnChart + 1
                let (streams, sales, units) = entry.computeUnits(weeks: weeksOnChart)

                var peak = existing.peak
                var weeksOnPeak = existing.weeksOnPeak
                if entry.rank < peak {
                    peak = entry.rank
                    weeksOnPeak = 1
                } else if entry.rank == peak {
                    weeksOnPeak += 1
                }

                rawAggregates[id] = ChartEntryAggregate(
                    parent: existing.parent,
                    rank: 0,
                    peak: peak,
                    weeksOnPeak: weeksOnPeak,
                    weeksOnChart: weeksOnChart,
                    streams: existing.streams + streams,
                    sales: existing.sales + sales,
                    totalUnits: existing.totalUnits + units,
                    certifications: nil)
            } else {
                let (streams, sales, units) = entry.computeUnits(weeks: 1)
                rawAggregates[id] = ChartEntryAggregate(
                    parent: entry,
                    rank: 0,
                    peak: entry.rank,
                    weeksOnPeak: 1,
                    weeksOnChart: 1,
                    streams: streams,
                    sales: sales,
                    totalUnits: units,
                    certifications: nil)
            }
        }

        func sortAggregates() -> [Dictionary<String, ChartEntryAggregate>.Element] {
            return rawAggregates.sorted { lhs, rhs in
                let lhs = lhs.value; let rhs = rhs.value

                let sortByTotalUnits: (ChartEntryAggregate, ChartEntryAggregate) -> Bool? = { lhs, rhs in
                    guard lhs.totalUnits != rhs.totalUnits else { return nil }
                    return lhs.totalUnits > rhs.totalUnits
                }

                let sortByStreams: (ChartEntryAggregate, ChartEntryAggregate) -> Bool? = { lhs, rhs in
                    guard lhs.streams != rhs.streams else { return nil }
                    return lhs.streams > rhs.streams
                }

                let sortBySales: (ChartEntryAggregate, ChartEntryAggregate) -> Bool? = { lhs, rhs in
                    guard lhs.sales != rhs.sales else { return nil }
                    return lhs.sales > rhs.sales
                }

                switch metric {
                case .streams:
                    return sortByStreams(lhs, rhs) ??
                           sortByTotalUnits(lhs, rhs) ??
                           sortBySales(lhs, rhs) ??
                           (lhs.parent.name < rhs.parent.name)
                case .sales:
                    return sortBySales(lhs, rhs) ??
                           sortByTotalUnits(lhs, rhs) ??
                           sortBySales(lhs, rhs) ??
                           (lhs.parent.name < rhs.parent.name)
                case .totalUnits:
                    return sortByTotalUnits(lhs, rhs) ??
                           sortBySales(lhs, rhs) ??
                           sortByStreams(lhs, rhs) ??
                           (lhs.parent.name < rhs.parent.name)
                }
            }
        }

        var sortedAggregates = sortAggregates()
        if let count = count {
            sortedAggregates = Array(sortedAggregates.prefix(count))
        }

        let aggregates = sortedAggregates.enumerated().map { index, element in
            let aggregate = element.value
            let certifications = getCertifications(for: aggregate.parent, totalUnits: aggregate.totalUnits)
            return ChartEntryAggregate(
                parent: aggregate.parent,
                rank: index + 1,
                peak: aggregate.peak,
                weeksOnPeak: aggregate.weeksOnPeak,
                weeksOnChart: aggregate.weeksOnChart,
                streams: aggregate.streams,
                sales: aggregate.sales,
                totalUnits: aggregate.totalUnits,
                certifications: certifications)
        }

        return aggregates
    }
}

struct SnapshotHistoryKey<Entry: ChartEntry>: Hashable{
    let entry: Entry
    let week: WeekRange
}

struct OverallHistoryKey<Entry: ChartEntry>: Hashable {
    let entry: Entry
    let year: Int?
}

struct YearEndChartKey: Hashable {
    let year: Int
    let metric: ChartMetric
}
