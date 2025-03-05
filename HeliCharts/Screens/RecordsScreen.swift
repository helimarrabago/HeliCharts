//
//  RecordsScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 2/2/25.
//

import SwiftUI

struct RecordsScreen: View {
    var body: some View {
        NavigationView {
            List {
                Section("Weekly records") {
                    NavigationLink {
                        WeeklyRecordScreen(recordType: .mostWeeklyUnits, viewModel: WeeklyRecordViewModel())
                    } label: {
                        Text("Most units in a single week")
                    }

                    NavigationLink {
                        WeeklyRecordScreen(recordType: .biggestDebuts, viewModel: WeeklyRecordViewModel())
                    } label: {
                        Text("Biggest weekly debuts")
                    }

                    NavigationLink {
                        WeeklyRecordScreen(recordType: .biggestPeaks, viewModel: WeeklyRecordViewModel())
                    } label: {
                        Text("Biggest weekly peaks")
                    }
                }

                Section("Fastest records") {
                    NavigationLink {
                        FastestRecordScreen(recordType: .milestoneUnits, viewModel: FastestRecordViewModel())
                    } label: {
                        Text("Fastest to reach milestone units")
                    }

                }
            }
            .navigationTitle("Records")
        }
    }
}

#Preview {
    RecordsScreen()
}
