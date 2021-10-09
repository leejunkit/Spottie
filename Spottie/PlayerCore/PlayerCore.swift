//
//  PlayerCore.swift
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

import Foundation
import Combine

class PlayerCore {
    class CaptureBag {
        let jsonDecoder = JSONDecoder()
        let currentState$: CurrentValueSubject<PlayerCoreState?, Never>
        init(stateSubject: CurrentValueSubject<PlayerCoreState?, Never>) {
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            currentState$ = stateSubject
        }
    }
    let captureBag: CaptureBag
    let curlClient: CurlClient

    private var state$: CurrentValueSubject<PlayerCoreState?, Never> = CurrentValueSubject(nil)
    var statePublisher: AnyPublisher<PlayerCoreState?, Never> {
        state$.eraseToAnyPublisher()
    }
    
    private var cancellables = [AnyCancellable]()
    
    init() {
        let socketPath = PlayerCore.getSocketPath()
        curlClient = CurlClient(socketPath: socketPath)
        captureBag = CaptureBag(stateSubject: state$)
        run(socketPath: socketPath)
    }
    
    static func getSocketPath() -> String {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "YW4H592L4M.ljk.spottie")!
        return container.appendingPathComponent("player_core.sock").path
    }
    
    func run(socketPath: String) {
        // https://oleb.net/blog/2015/06/c-callbacks-in-swift/
        let b = Unmanaged.passUnretained(captureBag);
        let t = Thread.init {
            librespot_init(socketPath, b.toOpaque()) { user_data, ptr, len  in
                guard let pointer = ptr else { return }
                let data = Data(bytes: pointer, count: Int(len))
                let bag: CaptureBag = Unmanaged.fromOpaque(user_data!).takeUnretainedValue();
                if let stateUpdate = try? bag.jsonDecoder.decode(PlayerCoreState.self, from: data) {
                    bag.currentState$.send(stateUpdate)
                }
                if let debugObj = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print(debugObj)
                }
            }
        }
        t.name = "ljk.spottie.PlayerCore"
        t.start()
    }
    
    private func waitForPlayerCoreToBeReady() async {
        return await withCheckedContinuation { continuation in
            statePublisher.compactMap { $0 }.first().sink { _ in
                continuation.resume()
            }.store(in: &cancellables)
        }
    }
    
    func token() async -> Result<TokenObject, CurlError> {
        await waitForPlayerCoreToBeReady()
        
        var req = URLRequest(url: URL(string: "http://localhost/token")!)
        req.httpMethod = "POST"
        let result = await curlClient.run(req)
        
        switch result {
        case .success(let received):
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let tokenObj = try? decoder.decode(TokenObject.self, from: received.data!)
            return Result.success(tokenObj!)
        case .failure(let err):
            return Result.failure(err)
        }
    }
    
    func play(_ trackIds: [String]) async {
        let jsonBody = try! JSONSerialization.data(withJSONObject: ["track_ids": trackIds], options: [])
        
        var req = URLRequest(url: URL(string: "http://localhost/queue/play")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonBody
        
        let result = await curlClient.run(req)
        switch result {
        case .failure(let err):
            print("Failure: \(err)")
        case .success(let response):
            print("Success! \(response)")
        }
    }
    
    func togglePlayback() async {
        var req = URLRequest(url: URL(string: "http://localhost/queue/toggle")!)
        req.httpMethod = "POST"
        let _ = await curlClient.run(req)
    }
    
    func next() async {
        var req = URLRequest(url: URL(string: "http://localhost/queue/next")!)
        req.httpMethod = "POST"
        let _ = await curlClient.run(req)
    }
    
    func previous() async {
        var req = URLRequest(url: URL(string: "http://localhost/queue/previous")!)
        req.httpMethod = "POST"
        let _ = await curlClient.run(req)
    }
    
    func seek(_ positionMs: Int) async {
        let jsonBody = try! JSONSerialization.data(withJSONObject: ["position_ms": positionMs], options: [])
        
        var req = URLRequest(url: URL(string: "http://localhost/player/seek")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonBody
        
        let _ = await curlClient.run(req)
    }
}
