//
//  Future+convenience.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

extension Future {
    static func success(_ output: Output) -> Future<Output, Failure> {
        return .init({ $0(.success(output)) })
    }

    static func failure(_ error: Failure) -> Future<Output, Failure> {
        return .init({ $0(.failure(error)) })
    }
}
