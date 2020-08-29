//
//  ServerSelectView.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 03/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import SwiftUI

struct ServerItemView: View {
    @ObservedObject
    private var viewModel: ServerListItemViewModel

    init(viewModel: ServerListItemViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Text(viewModel.description)
    }
}

struct ServerActionView: View {
    private var viewModel: ServerListItemViewModel?

    init(viewModel: ServerListItemViewModel?) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationLink(destination: viewModel?.testDestination()) {
            Text("Start Test")
                .bold()
        }
        .padding()
        .disabled(viewModel == nil)
    }
}

struct ServerSelectView: View {
    @State
    private var selectedServer: ServerListItemViewModel? = nil

    @ObservedObject
    private var viewModel: ServerListViewModel

    private let privacyPolicyHtml: String?

    private let lifetimeCancelBag = CancelBag()

    init(viewModel: ServerListViewModel) {
        self.viewModel = viewModel

        if let privacyPolicyUrl = Bundle.main.url(forResource: "privacy_en", withExtension: "html") {
            let fileData = try? Data(contentsOf: privacyPolicyUrl, options: .mappedIfSafe)
            privacyPolicyHtml = fileData.map { String(data: $0, encoding: .utf8) } ?? nil
        } else {
            privacyPolicyHtml = nil
        }
    }

    var body: some View {
        return NavigationView {
            VStack {
                Spacer()

                Text("Choose a server.")
                    .font(.largeTitle)

                Picker("Server selection", selection: $selectedServer) {
                    ForEach(viewModel.serverList, id: \.description) {
                        ServerItemView(viewModel: $0).tag($0 as ServerListItemViewModel?)
                    }
                }.labelsHidden().id(viewModel.incrementingWorkaroundForPicker)

                Spacer()

                ServerActionView(viewModel: selectedServer ?? viewModel.serverList.first)

                Spacer()
                Spacer()
                Spacer()

                privacyPolicyHtml.map {
                    NavigationLink(
                        destination: HTMLStringView(htmlContent: $0).navigationBarTitle("Privacy Policy", displayMode: .inline)
                    ) {
                        Text("Privacy Policy")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }.padding()
                }
            }
        }
    }
}
