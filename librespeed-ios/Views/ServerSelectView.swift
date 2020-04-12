//
//  ServerSelectView.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 03/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import SwiftUI

struct ServerSelectView: View {
    @State private var server = "gg"

    var body: some View {
        VStack {
            Spacer()

            Text("Choose a server.")
                .font(.largeTitle)

            Picker("Server selection", selection: $server) {
                ForEach(["Helsinki, Vaanguard (50ms)", "dudazura mam (222ms)", "Prague, Czehicia (2ms)", "Slovanskkia, Bratko (45ms)"], id: \.description) {
                    Text($0)
                }
            }.labelsHidden()

            Button(action: startTest) {
                Text("Start Test")
                    .bold()
            }.padding()

            Spacer()
            Spacer()

            Button(action: showPrivacyPolicy) {
                Text("Privacy Policy")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }.padding()
        }
    }

    private func showPrivacyPolicy() {

    }

    private func startTest() {

    }
}
