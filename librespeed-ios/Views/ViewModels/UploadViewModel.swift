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

    private var completionHandler: (() -> Void)?

    private var start: TimeInterval!

    private var task: URLSessionUploadTask!

    private let queue = OperationQueue()

    func startTest(completionHandler: (() -> Void)? = nil) throws {
        var bytes = [UInt8](repeating: 0, count: Constants.Upload.sizeBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else { throw UploadTestError.dataGenerationError }

        let dummyData = Data(bytes)

        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: queue)
        guard let url = URL(string: "https://fi.openspeed.org/empty.php") else { throw UploadTestError.invalidUrl }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        task = session.uploadTask(with: request, from: dummyData)
        task.priority = URLSessionTask.highPriority

        self.completionHandler = completionHandler

        start = Date.timeIntervalSinceReferenceDate
        task.resume()
    }
}

extension UploadViewModel: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            completionHandler?()
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
