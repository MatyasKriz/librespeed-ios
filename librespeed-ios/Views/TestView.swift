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
    private var ping = PingViewModel()
    @ObservedObject
    private var download = DownloadViewModel()
    @ObservedObject
    private var upload = UploadViewModel()

    @State
    private var downloadLimit = 100.0
    @State
    private var uploadLimit = 100.0

    private var cancelables: Set<AnyCancellable> = []

    var body: some View {
        VStack {
            Spacer().layoutPriority(1)

            Text("Testing..")
                .font(.largeTitle)

            HStack(alignment: .top, spacing: 44) {
                VStack {
                    Text("Ping")
                    format(ping: ping.ping)
                }
                VStack {
                    Text("Jitter")
                    format(ping: ping.jitter)
                }
            }.padding()

            HStack(alignment: .top, spacing: 44) {
                VStack {
                    ArcProgressBar(value: download.value, limit: downloadLimit)
                    Text("Mbps").font(.system(size: 20))
                }
                VStack {
                    ArcProgressBar(value: upload.value, limit: uploadLimit)
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
        try! self.ping.startTest() {
            try! self.download.startTest {
                try! self.upload.startTest()
            }
        }
    }

    private func format(ping: Double) -> Group<Text> {
        let result: (value: String, unit: String)?
        if ping >= 1 {
            result = Formatters.secondFormatter.string(for: ping).map { ($0, "s") }
        } else {
            let milliseconds = ping * 1000
            result = Formatters.millisecondFormatter.string(for: milliseconds).map { ($0, "ms") }
        }

        if let result = result {
            return Group {
                Text(result.value).font(.title) +
                    Text(result.unit)
            }
        } else {
            return Group {
                Text("N/A").font(.title)
            }
        }
    }
}

struct ArcProgressBar: View {
    var value: Double
    var limit: Double

    var body: some View {
        ZStack {
            Text(Formatters.speedFormatter.string(from: NSNumber(value: value)) ?? "0.0")
                .font(.system(size: 20))

            ZStack {
                Path { path in
                    path.addArc(center: CGPoint(x: 56, y: 44), radius: 50, startAngle: .degrees(130), endAngle: .degrees(50), clockwise: false)
                }.stroke(Color(white: 0.8), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: 112, height: 80, alignment: .center)

                Path { path in
                    path.addArc(center: CGPoint(x: 56, y: 44), radius: 50, startAngle: .degrees(130), endAngle: .degrees(getProgressEndAngle()), clockwise: false)
                }.stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: 112, height: 80, alignment: .center)
                    .animation(.easeIn)
            }
        }
    }

    private func getProgressEndAngle() -> Double {
        // 130° -> 360° -> 50°
        let maxAngle: Double = 280
        let trimmedValue = min(value, limit)
        return trimmedValue / limit * maxAngle + 130
    }
}
