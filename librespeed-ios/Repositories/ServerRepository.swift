//
//  ServerRepository.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class ServerRepository {
    func serverList() -> Future<[ServerEntity], ServerError> {
        guard let serverListUrl = Bundle.main.url(forResource: "ServerList", withExtension: "json") else {
            print("ERROR: Failed to fetch server list from file.")
            return .failure(.fileNotFound)
        }

        do {
            let fileData = try Data(contentsOf: serverListUrl, options: .mappedIfSafe)
            let serverEntities = try JSONDecoder().decode([ServerEntity].self, from: fileData)
            return .success(serverEntities)
        } catch {
            return .failure(.readFailed)
        }
    }

    enum ServerError: Error {
        case unknown
        case fileNotFound
        case readFailed
    }
}
