//
//  ServerModel.swift
//  librespeed-ios
//
//  Created by Matyáš Kříž on 20/06/2020.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import Combine

final class ServerModel: NSObject, ObservableObject {
    var name: String
    var paths: Paths

    @Published
    private(set) var download = 0.0

    @Published
    private(set) var upload = 0.0

    @Published
    private(set) var ping = 0.0

    @Published
    private(set) var jitter = 0.0

    private var downloadCancelBag = CancelBag()
    private var uploadCancelBag = CancelBag()
    private var pingCancelBag = CancelBag()

    init?(
        name: String,
        host: String,
        paths: [String: String]
    ) {
        self.name = name

        guard let hostUrl = URL(string: host) else { return nil }

        guard let paths = Paths(host: hostUrl, paths: paths) else { return nil }
        self.paths = paths
    }

    func reset() {
        download = 0
        upload = 0
        ping = 0
        jitter = 0
    }

    func testDownload() -> AnyPublisher<Void, Error> {
        return Deferred<AnyPublisher<Void, Error>> { [weak self] in
            guard let self = self else { return Empty().eraseToAnyPublisher() }

            let subject = PassthroughSubject<Void, Error>()
            var cancellable: Cancellable?
            return subject.handleEvents(
                receiveSubscription: { _ in
                    cancellable = DownloadModel(url: self.paths.download)
                        .startTest()
                        .sink(
                            receiveCompletion: { _ in subject.send(completion: .finished) },
                            receiveValue: { [weak self] in self?.download = $0 }
                        )
                },
                receiveCancel: {
                    cancellable?.cancel()
                }
            ).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func testUpload() -> AnyPublisher<Void, Error> {
        return Deferred<AnyPublisher<Void, Error>> { [weak self] in
            guard let self = self else { return Empty().eraseToAnyPublisher() }

            let subject = PassthroughSubject<Void, Error>()
            var cancellable: Cancellable?
            return subject.handleEvents(
                receiveSubscription: { _ in
                    cancellable = UploadModel(url: self.paths.upload)
                        .startTest()
                        .sink(
                            receiveCompletion: { _ in subject.send(completion: .finished) },
                            receiveValue: { [weak self] in self?.upload = $0 }
                        )
                },
                receiveCancel: {
                    cancellable?.cancel()
                }
            ).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func testPing(attempts: Int? = nil) -> AnyPublisher<Void, Error> {
        return Deferred<AnyPublisher<Void, Error>> { [weak self] in
            guard let self = self else { return Empty().eraseToAnyPublisher() }

            let subject = PassthroughSubject<Void, Error>()
            var cancellable: Cancellable?
            return subject.handleEvents(
                receiveSubscription: { _ in
                    cancellable = PingModel(url: self.paths.ping)
                        .startTest(attempts: attempts)
                        .sink(
                            receiveCompletion: { _ in subject.send(completion: .finished) },
                            receiveValue: { [weak self] ping, jitter in
                                self?.ping = ping
                                self?.jitter = jitter
                            }
                        )
                },
                receiveCancel: {
                    cancellable?.cancel()
                }
            ).eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    struct Paths {
        var download: URL
        var upload: URL
        var ping: URL
        var ip: URL

        init?(host: URL, paths: [String: String]) {
            let pathUrls = paths.compactMapValues { URL(string: $0, relativeTo: host) }

            guard
                let download = pathUrls["download"],
                let upload = pathUrls["upload"],
                let ip = pathUrls["ip"] else { return nil }

            self.download = download
            self.upload = upload
            self.ping = pathUrls["ping"] ?? upload
            self.ip = ip
        }
    }
}
