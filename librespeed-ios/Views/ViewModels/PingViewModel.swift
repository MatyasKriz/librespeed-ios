//
//  PingViewModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 13/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

final class PingViewModel: NSObject, ObservableObject {
    @Published
    private(set) var ping = 0.0
    @Published
    private(set) var jitter = 0.0

    private var attempt = 1

    private var completionHandler: (() -> Void)?

    private var start: TimeInterval!

    private var session: URLSession!
    private var url: URL!
    private var task: URLSessionDataTask!

    private let queue = OperationQueue()

    func startTest(completionHandler: (() -> Void)? = nil) throws {
        ping = 0
        jitter = 0
        attempt = 1

        self.completionHandler = completionHandler

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
        guard let url = URL(string: "https://fi.openspeed.org/empty.php") else { throw PingTestError.invalidUrl }
        self.url = url

        pingServer()
    }

    private func pingServer() {
        task = session.dataTask(with: url)
        task.priority = URLSessionTask.highPriority

        start = Date.timeIntervalSinceReferenceDate
        task.resume()
    }

    private func updateValues() {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - self.start

        let newJitter: Double
        if ping == 0 {
            newJitter = 0
        } else {
            let difference = abs(ping - timeElapsed)
            // Set priorities of the old and new value.
            let priority: (old: Double, new: Double) = difference > jitter ? (0.3, 0.7) : (0.8, 0.2)
            newJitter = jitter * priority.old + difference * priority.new
        }

        DispatchQueue.main.async {
            self.ping = timeElapsed
            self.jitter = newJitter
        }
    }
}

extension PingViewModel: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            updateValues()
            if attempt >= Constants.Ping.attempts {
                completionHandler?()
            } else {
                attempt += 1
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + Constants.Ping.requestPadding) {
                    self.pingServer()
                }
            }
        }
    }
}

extension PingViewModel {
    enum PingTestError: Error {
        case unknown
        case invalidUrl
    }
}
