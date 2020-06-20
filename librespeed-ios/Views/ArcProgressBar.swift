//
//  ArcProgressBar.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import SwiftUI

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
