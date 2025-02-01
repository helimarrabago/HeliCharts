//
//  IndexViewModel.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Combine
import Foundation

protocol IndexViewModelProtocol: ObservableObject {
    init()
    func fetchUser() async throws -> UserUIModel
}

final class IndexViewModel: IndexViewModelProtocol {
    func fetchUser() async throws -> UserUIModel {
        let url = LastFM.createURL(method: .userInfo)!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(UserResponse.self, from: data)

        let user = User(response: response)
        UserRepository.user.send(user)

        return UserUIModel(user: user)
    }
}
