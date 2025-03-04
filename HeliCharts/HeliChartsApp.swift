//
//  HeliChartsApp.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/7/25.
//

import SwiftUI
import SwiftData

@main
struct HeliChartsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            IndexScreen<IndexViewModel>()
                .environmentObject(IndexViewModel())
        }
        .modelContainer(sharedModelContainer)
    }
}
