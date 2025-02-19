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
                    MostWeeklyUnitsScreen(viewModel: MostWeeklyUnitsViewModel())
                } label: {
                    Text("Most units in a single week")
                }

                Text("Longest running #1 entries")
            }
            .navigationTitle("Records")
        }
    }
}

#Preview {
    RecordsScreen()
}
