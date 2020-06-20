//
//  CancelBag.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class CancelBag {
    private var cancellables: Set<AnyCancellable> = []

    func add(cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }
}
