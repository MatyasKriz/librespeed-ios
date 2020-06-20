//
//  ServerService.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Combine

final class ServerService {
    private let serverRepository: ServerRepository

    init(serverRepository: ServerRepository) {
        self.serverRepository = serverRepository
    }

    func serverList() -> AnyPublisher<[ServerModel], ServerError> {
        return serverRepository.serverList()
            .map {
                $0.compactMap { serverEntity in
                    ServerModel(
                        name: serverEntity.name,
                        host: serverEntity.host,
                        paths: serverEntity.paths
                    )
                }
            }
            .mapError { _ in ServerError.unknown }
            .eraseToAnyPublisher()
    }

    enum ServerError: Error {
        case unknown
    }
}
