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
        static let size = 100
    }

    struct Upload {
        static let size = 20
        static let sizeBytes = size * bytesPerMegaByte
    }
}
