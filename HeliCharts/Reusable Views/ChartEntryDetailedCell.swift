//
//  ChartEntryDetailedCell.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/22/25.
//

import SwiftUI

struct ChartEntryDetailedCell: View {
    let rank: String
    let movement: ChartMovementUIModel?
    let title: String
    let peak: String
    let weeks: String
    let streams: String
    let sales: String
    let units: String
    let certifications: [Certification]?

    init(entry: ChildChartEntryUIModel) {
        self.rank = entry.rank
        self.movement = nil
        self.title = entry.title
        self.peak = entry.peak
        self.weeks = entry.weeks
        self.streams = entry.streams
        self.sales = entry.sales
        self.units = entry.units
        self.certifications = entry.certifications
    }

    init(entry: YearEndChartEntryUIModel) {
        self.rank = entry.rank
        self.movement = entry.movement
        self.title = entry.title
        self.peak = entry.peak
        self.weeks = entry.weeks
        self.streams = entry.streams
        self.sales = entry.sales
        self.units = entry.units
        self.certifications = entry.certifications
    }

    init(entry: AllTimeChartEntryUIModel) {
        self.rank = entry.rank
        self.movement = nil
        self.title = entry.title
        self.peak = entry.peak
        self.weeks = entry.weeks
        self.streams = entry.streams
        self.sales = entry.sales
        self.units = entry.units
        self.certifications = entry.certifications
    }

    var body: some View {
        HStack(alignment: .top) {
            rankView
            VStack(alignment: .leading, spacing: 8) {
                infoView
                unitsView
                if let certifications = certifications {
                    certificationsView(certifications)
                }
            }
        }
    }
}

private extension ChartEntryDetailedCell {
    var rankView: some View {
        VStack {
            Text(rank)
                .font(.title2)
                .fontWeight(.semibold)

            if let movement = movement {
                Text(movement.symbol)
                    .font(.footnote)
                    .foregroundStyle(movement.color)
            }
        }
        .frame(width: 40)
    }

    var infoView: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            HStack {
                Text("Peak: \(peak)")
                    .font(.caption)

                Text("Weeks: \(weeks)")
                    .font(.caption)
            }
        }
    }

    var unitsView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Streams: " + streams)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)

                Text("Sales: " + sales)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }

            Text("Total Units: " + units)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }

    func certificationsView(_ certifications: [Certification]) -> some View {
        let certifications = Array(zip(certifications.indices, certifications))
        return HStack {
            ForEach(certifications, id: \.0) { index, certification in
                HStack {
                    certification.icon
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(certification.formatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    if index < certifications.count - 1 {
                        Text("+")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        ChartEntryDetailedCell(entry: ChildChartEntryUIModel(
            id: "1",
            title: "BODYGUARD",
            rank: "1",
            peak: "#1 (2x)",
            weeks: "30",
            streams: "1,900,000,000",
            sales: "2,627,000",
            units: "7,154,000",
            certifications: [.platinum(count: 7)],
            parent: MockChartEntry()))
    }
    .listStyle(.plain)
}
