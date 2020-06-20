//
//  ServerListItemViewModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

final class ServerListItemViewModel: Identifiable, Hashable, ObservableObject {
    typealias Id = Int

    let id: Id

    let testDestination: () -> TestView

    @Published
    private(set) var description: String

    private let name: String

    private let lifetimeCancelBag = CancelBag()

    init(id: Id, serverModel: ServerModel, testDestination: @escaping () -> TestView) {
        self.id = id
        self.name = serverModel.name
        description = name
        self.testDestination = {
            return testDestination()
        }

        serverModel.testPing(attempts: 3)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .cancelled(by: lifetimeCancelBag)

        serverModel.$ping
            // The first is too high to be a real value.
            .dropFirst()
            .map { $0 > 0 ? Formatters.format(ping: $0).map { "\($0.value)\($0.unit)" } : nil }
            .map { serverModel.name + ($0.map { " (\($0))" } ?? "") }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { self.description = $0 })
            .cancelled(by: lifetimeCancelBag)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }

    static func ==(lhs: ServerListItemViewModel, rhs: ServerListItemViewModel) -> Bool {
        return lhs.description == rhs.description
    }
}
