//
//  ServerListViewModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class ServerListViewModel: ObservableObject {
    @Published
    private(set) var serverList: [ServerListItemViewModel] = []

    // Apparently, SwiftUI's Picker is not doing so hot with dynamic data, so this counter is used to manually force view redraw.
    @Published
    private(set) var incrementingWorkaroundForPicker = 0

    private let serverService: ServerService
    private let testDestination: (ServerModel) -> TestView

    private let lifetimeCancelBag = CancelBag()

    init(
        serverService: ServerService,
        testDestination: @escaping (ServerModel) -> TestView
    ) {
        self.serverService = serverService
        self.testDestination = testDestination

        serverService.serverList()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { serverList in
                    self.serverList = serverList.enumerated().map { index, serverModel in
                        ServerListItemViewModel(
                            id: index,
                            serverModel: serverModel,
                            testDestination: { self.testDestination(serverModel) }
                        )
                    }
                    self.incrementingWorkaroundForPicker += 1
                }
            )
            .cancelled(by: lifetimeCancelBag)
    }
}
