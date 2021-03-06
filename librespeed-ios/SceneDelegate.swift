//
//  SceneDelegate.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 03/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let serverService = ServerService(serverRepository: ServerRepository())
        let viewModel = ServerListViewModel(
            serverService: serverService,
            testDestination: { TestView(viewModel: TestViewModel(serverModel: $0)) }
        )
        let initialView = ServerSelectView(viewModel: viewModel)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: initialView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
