//
//  DownloadModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class DownloadModel: NSObject, ObservableObject {
    private var start: TimeInterval!

    private var session: URLSession!
    private var task: URLSessionDownloadTask!

    private let queue = OperationQueue()

    private let speedSubject = CurrentValueSubject<Double, DownloadTestError>(0)

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func startTest() -> AnyPublisher<Double, DownloadTestError> {
        // Reset the value.
        speedSubject.send(0)

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return Fail<Double, DownloadTestError>(error: .invalidUrl).eraseToAnyPublisher()
        }

        urlComponents.queryItems = [URLQueryItem(name: "ckSize", value: String(Constants.Download.size))]

        guard let finalUrl = urlComponents.url else {
            return Fail<Double, DownloadTestError>(error: .unknown).eraseToAnyPublisher()
        }

        task = session.downloadTask(with: finalUrl)
        task.priority = URLSessionTask.highPriority

        start = Date.timeIntervalSinceReferenceDate
        task.resume()

        return speedSubject.eraseToAnyPublisher()
    }
}

extension DownloadModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        speedSubject.send(completion: .finished)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - start
        let speedB = Double(totalBytesWritten) / timeElapsed
        let speed = 8 * speedB * Constants.overheadCompensationFactor / Double(Constants.bytesPerMegaByte)

//        print("Download", speedB, speed, separator: "\n\t")
        speedSubject.send(speed)
    }
}

extension DownloadModel {
    enum DownloadTestError: Error {
        case unknown
        case invalidUrl
    }
}
