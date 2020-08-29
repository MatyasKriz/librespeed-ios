//
//  HTMLStringView.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 29/08/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import WebKit
import SwiftUI

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
