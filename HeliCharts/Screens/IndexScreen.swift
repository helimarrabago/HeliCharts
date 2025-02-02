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
            topChartEntriesView
                .tabItem {
                    Label("Weekly", systemImage: "calendar")
                }

            yearEndChartsView
                .tabItem {
                    Label("Year-end", systemImage: "music.note.list")
                }

            allTimeChartsView
                .tabItem {
                    Label("All-time", systemImage: "chart.bar.xaxis.ascending.badge.clock")
                }

            NavigationView {
                Text("Soon")
                    .navigationTitle("Records")
            }
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
    var topChartEntriesView: some View {
        TopChartEntriesScreen(viewModel: TopChartEntriesViewModel())
    }

    var yearEndChartsView: some View {
        YearEndChartsScreen(viewModel: YearEndChartsViewModel())
    }

    var allTimeChartsView: some View {
        AllTimeChartsScreen(viewModel: AllTimeChartsViewModel())
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
