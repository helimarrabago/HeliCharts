//
//  IndexScreen.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/7/25.
//

import SwiftUI

struct IndexScreen<ViewModel: IndexViewModelProtocol>: View {
    @StateObject var viewModel = ViewModel()
    @State private var user: UserUIModel?

    var body: some View {
        TabView {
            topChartEntriesScreen
                .tabItem {
                    Label("Weekly", systemImage: "calendar")
                }

            yearEndChartsScreen
                .tabItem {
                    Label("Year-end", systemImage: "music.note.list")
                }

            allTimeChartsScreen
                .tabItem {
                    Label("All-time", systemImage: "chart.bar.xaxis.ascending.badge.clock")
                }

            recordsScreen
                .tabItem {
                    Label("Records", systemImage: "trophy")
                }
        }
        .task {
            do {
                let user = try await viewModel.fetchUser()
                withAnimation {
                    self.user = user
                }
            } catch {
                print(error)
            }
        }
    }
}

private extension IndexScreen {
    var topChartEntriesScreen: some View {
        TopChartEntriesScreen(viewModel: TopChartEntriesViewModel())
    }

    var yearEndChartsScreen: some View {
        YearEndChartsScreen(viewModel: YearEndChartsViewModel())
    }

    var allTimeChartsScreen: some View {
        AllTimeChartsScreen(viewModel: AllTimeChartsViewModel())
    }

    var recordsScreen: some View {
        RecordsScreen()
    }
}

#Preview {
    final class MockViewModel: IndexViewModelProtocol {
        func fetchUser() async throws -> UserUIModel {
            return UserUIModel(name: "helimarrabago")
        }
    }

    return IndexScreen<MockViewModel>()
}
