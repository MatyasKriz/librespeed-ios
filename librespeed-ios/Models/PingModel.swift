//
//  PingModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class PingModel: NSObject, ObservableObject {
    typealias Values = (ping: Double, jitter: Double)

    private var attempts = 0
    private var attempt = 1

    private var start: TimeInterval!

    private var session: URLSession!
    private var task: URLSessionDataTask!

    private let queue = OperationQueue()

    private let pingSubject = CurrentValueSubject<Values, PingTestError>((ping: 0, jitter: 0))

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func startTest(attempts: Int?) -> AnyPublisher<Values, PingTestError> {
        // Reset the values.
        pingSubject.send((ping: 0, jitter: 0))

        self.attempts = attempts ?? Constants.Ping.attempts
        attempt = 1

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)

        pingServer()

        return pingSubject.eraseToAnyPublisher()
    }

    private func pingServer() {
        task = session.dataTask(with: url)
        task.priority = URLSessionTask.highPriority

        start = Date.timeIntervalSinceReferenceDate
        task.resume()
    }

    private func updateValues() {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - self.start
        let ping = pingSubject.value.ping
        let jitter = pingSubject.value.jitter

        let newJitter: Double
        if ping == 0 {
            newJitter = 0
        } else {
            let difference = abs(ping - timeElapsed)
            // Set priorities of the old and new value.
            let priority: (old: Double, new: Double) = difference > jitter ? (0.3, 0.7) : (0.8, 0.2)
            newJitter = jitter * priority.old + difference * priority.new
        }

        pingSubject.send((ping: timeElapsed, jitter: newJitter))
    }
}

extension PingModel: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            pingSubject.send(completion: .failure(.unknown))
        } else {
            updateValues()
            if attempt < attempts {
                attempt += 1
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + Constants.Ping.requestPadding) {
                    self.pingServer()
                }
            } else {
                pingSubject.send(completion: .finished)
            }
        }
    }
}

extension PingModel {
    enum PingTestError: Error {
        case unknown
    }
}
