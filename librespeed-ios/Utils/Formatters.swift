//
//  Formatters.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 05/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

struct Formatters {
    static let speedFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        return formatter
    }()

    static let secondFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let millisecondFormatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        formatter.alwaysShowsDecimalSeparator = false
        return formatter
    }()
}
