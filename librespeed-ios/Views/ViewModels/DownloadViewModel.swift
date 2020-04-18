//
//  DownloadViewModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 03/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

final class DownloadViewModel: NSObject, ObservableObject {
    @Published
    private(set) var value = 0.0

    private var completionHandler: (() -> Void)?

    private var start: TimeInterval!

    private var session: URLSession!
    private var task: URLSessionDownloadTask!

    private let queue = OperationQueue()

    func startTest(completionHandler: (() -> Void)? = nil) throws {
        DispatchQueue.main.async {
            self.value = 0
        }

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
        guard let url = URL(string: "https://fi.openspeed.org/garbage.php"),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw DownloadTestError.invalidUrl }

        urlComponents.queryItems = [URLQueryItem(name: "ckSize", value: String(Constants.Download.size))]

        guard let finalUrl = urlComponents.url else { throw DownloadTestError.unknown }

        task = session.downloadTask(with: finalUrl)
        task.priority = URLSessionTask.highPriority

        self.completionHandler = completionHandler

        start = Date.timeIntervalSinceReferenceDate
        task.resume()
    }
}

extension DownloadViewModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        completionHandler?()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - start
        let speedB = Double(totalBytesWritten) / timeElapsed
        let speed = 8 * speedB * Constants.overheadCompensationFactor / Double(Constants.bytesPerMegaByte)

        print("Download", speedB, speed, separator: "\n\t")
        DispatchQueue.main.async {
            self.value = speed
        }
    }
}

extension DownloadViewModel {
    enum DownloadTestError: Error {
        case unknown
        case invalidUrl
    }
}
