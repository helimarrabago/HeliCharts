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
                NavigationLink {
                    WeeklyRecordScreen(recordType: .mostWeeklyUnits, viewModel: WeeklyRecordViewModel())
                } label: {
                    Text("Most units in a single week")
                }

                NavigationLink {
                    WeeklyRecordScreen(recordType: .biggestDebuts, viewModel: WeeklyRecordViewModel())
                } label: {
                    Text("Biggest debuts")
                }
            }
            .navigationTitle("Records")
        }
    }
}

#Preview {
    RecordsScreen()
}
