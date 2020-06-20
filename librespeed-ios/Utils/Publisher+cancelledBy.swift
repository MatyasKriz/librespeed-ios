//
//  Publisher+cancelledBy.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

extension AnyCancellable {
    func cancelled(by cancelBag: CancelBag) {
        cancelBag.add(cancellable: self)
    }
}
