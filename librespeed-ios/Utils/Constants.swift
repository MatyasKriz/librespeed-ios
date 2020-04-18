//
//  Constants.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 12/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

struct Constants {
    static let bytesPerMegaByte = 1048576
    static let overheadCompensationFactor = 1.06

    struct Download {
        static let size = 30
    }

    struct Upload {
        static let size = 5
        static let sizeBytes = size * bytesPerMegaByte
        static let attempts = 1
        static let requestPadding = 0.0
    }

    struct Ping {
        static let attempts = 10
        static let requestPadding = 0.075
    }
}
