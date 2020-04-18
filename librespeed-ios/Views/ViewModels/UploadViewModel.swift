//
//  UploadViewModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 03/04/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation

final class UploadViewModel: NSObject, ObservableObject {
    @Published
    private(set) var value = 0.0

    private var attempt = 1

    private var completionHandler: (() -> Void)?

    private var start: TimeInterval!

    private var session: URLSession!
    private var url: URL!
    private var task: URLSessionUploadTask!

    private let queue = OperationQueue()

    private var dummyData: Data!

    func startTest(completionHandler: (() -> Void)? = nil) throws {
        DispatchQueue.main.async {
            self.value = 0
        }

        self.completionHandler = completionHandler

        var bytes = [UInt8](repeating: 0, count: Constants.Upload.sizeBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        dummyData = Data(bytes)

        guard status == errSecSuccess else { throw UploadTestError.dataGenerationError }

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
        guard let url = URL(string: "https://fi.openspeed.org/empty.php") else { throw UploadTestError.invalidUrl }
        self.url = url

        uploadToServer()
    }

    private func uploadToServer() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        task = session.uploadTask(with: request, from: dummyData)
        task.priority = URLSessionTask.highPriority

        start = Date.timeIntervalSinceReferenceDate
        task.resume()
    }
}

extension UploadViewModel: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            if attempt >= Constants.Upload.attempts {
                completionHandler?()
            } else {
                attempt += 1
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + Constants.Upload.requestPadding) {
                    self.uploadToServer()
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - start
        let speedB = Double(totalBytesSent) / timeElapsed
        let speed = 8 * speedB * Constants.overheadCompensationFactor / Double(Constants.bytesPerMegaByte)

        print("Upload", speedB, speed, separator: "\n\t")
        DispatchQueue.main.async {
            self.value = speed
        }
    }
}

extension UploadViewModel {
    enum UploadTestError: Error {
        case unknown
        case dataGenerationError
        case invalidUrl
    }
}
