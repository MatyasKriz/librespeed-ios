//
//  UploadModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class UploadModel: NSObject, ObservableObject {
    private var attempt = 1

    private var start: TimeInterval!

    private var session: URLSession!
    private var task: URLSessionUploadTask!

    private let queue = OperationQueue()

    private var dummyData: Data!

    private let speedSubject = CurrentValueSubject<Double, UploadTestError>(0)

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func startTest() -> AnyPublisher<Double, UploadTestError> {
        speedSubject.send(0)

        var bytes = [UInt8](repeating: 0, count: Constants.Upload.sizeBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        dummyData = Data(bytes)

        guard status == errSecSuccess else {
            return Fail<Double, UploadTestError>(error: .dataGenerationError).eraseToAnyPublisher()
        }

        session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)

        uploadToServer()

        return speedSubject.eraseToAnyPublisher()
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

extension UploadModel: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            speedSubject.send(completion: .failure(.unknown))
        } else {
            if attempt < Constants.Upload.attempts {
                attempt += 1
                DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + Constants.Upload.requestPadding) {
                    self.uploadToServer()
                }
            } else {
                speedSubject.send(completion: .finished)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let timeElapsed = Date.timeIntervalSinceReferenceDate - start
        let speedB = Double(totalBytesSent) / timeElapsed
        let speed = 8 * speedB * Constants.overheadCompensationFactor / Double(Constants.bytesPerMegaByte)

//        print("Upload", speedB, speed, separator: "\n\t")
        speedSubject.send(speed)
    }
}

extension UploadModel {
    enum UploadTestError: Error {
        case unknown
        case dataGenerationError
        case invalidUrl
    }
}
