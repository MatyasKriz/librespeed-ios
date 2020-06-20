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

    private let lifetimeCancelBag = CancelBag()

    init(viewModel: ServerListViewModel) {
        self.viewModel = viewModel
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

                Button(action: showPrivacyPolicy) {
                    Text("Privacy Policy")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }.padding()
            }
        }
    }

    private func showPrivacyPolicy() {
        
    }
}
