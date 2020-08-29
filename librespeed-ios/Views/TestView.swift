//
//  TestView.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 05/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import SwiftUI
import Combine

struct TestView: View {
    @ObservedObject
    private var viewModel: TestViewModel

    init(viewModel: TestViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Spacer().layoutPriority(1)

            Text("Testing..")
                .font(.largeTitle)

            HStack(alignment: .top, spacing: 44) {
                VStack {
                    Text("Ping")
                    format(ping: viewModel.ping)
                }
                VStack {
                    Text("Jitter")
                    format(ping: viewModel.jitter)
                }
            }.padding()

            HStack(alignment: .top, spacing: 44) {
                VStack {
                    Text("Download")
                    Spacer(minLength: 16)
                    ArcProgressBar(value: viewModel.download, limit: viewModel.downloadLimit)
                    Text("Mbps").font(.system(size: 20))
                }
                VStack {
                    Text("Upload")
                    Spacer(minLength: 16)
                    ArcProgressBar(value: viewModel.upload, limit: viewModel.uploadLimit)
                    Text("Mbps").font(.system(size: 20))
                }
            }.layoutPriority(1)

            Spacer().layoutPriority(1)
            Spacer().layoutPriority(1)
        }
        .onAppear {
            self.startTests()
        }
    }

    private func startTests() {
        viewModel.test()
    }

    private func format(ping: Double) -> Group<Text> {
        let formattedPing = Formatters.format(ping: ping)

        if let formattedPing = formattedPing {
            return Group {
                Text(formattedPing.value).font(.title) +
                    Text(formattedPing.unit)
            }
        } else {
            return Group {
                Text("N/A").font(.title)
            }
        }
    }
}
