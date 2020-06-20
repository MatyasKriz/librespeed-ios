//
//  ServerEntity.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

struct ServerEntity: Decodable {
    var name: String
    var host: String
    var paths: [String: String]

    struct Paths: Decodable {
        var download: String
        var upload: String
        var ping: String?
        var ip: String
    }
}
