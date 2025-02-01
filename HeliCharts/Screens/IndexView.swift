//
//  IndexView.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/7/25.
//

import SwiftUI

struct IndexView<ViewModel: IndexViewModelProtocol>: View {
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

private extension IndexView {
    var topChartEntriesView: some View {
        TopChartEntriesView(viewModel: TopChartEntriesViewModel())
    }

    var yearEndChartsView: some View {
        YearEndChartsView(viewModel: YearEndChartsViewModel())
    }

    var allTimeChartsView: some View {
        AllTimeChartsView(viewModel: AllTimeChartsViewModel())
    }
}

#Preview {
    final class MockViewModel: IndexViewModelProtocol {
        func fetchUser() async throws -> UserUIModel {
            return UserUIModel(name: "helimarrabago")
        }
    }

    return IndexView<MockViewModel>()
}
