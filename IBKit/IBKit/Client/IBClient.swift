//
//  IBClient.swift
//	IBKit
//
//	Copyright (c) 2016-2023 Sten Soosaar
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//


import Foundation
import Combine
import NIOCore
import NIOConcurrencyHelpers
import NIOPosix

open class IBClient {
    internal var subject = PassthroughSubject<IBEvent,Never>()
    lazy public var eventFeed = subject.share().eraseToAnyPublisher()
    
    var identifier: Int
    var connection: IBConnection?
    
    let host: String
    let port: Int
    
    var serverVersion: Int?
    
    public var connectionTime: String?
    
    
    /// Creates new api client.
    /// - Parameter id: Master API ID, set in IB Gateway or Workstation
    /// - Parameter address: Address where your IB Gatweay / Worskatation is running
    

    public init(id masterID: Int, address: String, port: Int) {
        guard let host = URL(string: address)?.host else {
            fatalError("Cant figure out the host to connect")
        }
        
        self.host = host
        self.port = port
        self.identifier = masterID
        
    }


    var _nextValidID: Int = 0

    /// Return next valid request identifier you should use to make request or subscription

    public var nextRequestID: Int {
        let value = _nextValidID
        _nextValidID += 1
        return value
    }
    
    /// Disconnect client from IB Gateway or Workstation
    ///
    public func connect() throws {
        guard connection == nil else {
            throw IBError.connectionError("Already connected")
        }

        let connection = try IBConnection(host: host, port: port)
        connection.didStopCallback = didStopCallback(error:)
        connection.stateDidChangeCallback =  stateDidChange(to:)
        connection.delegate = self
        self.connection = connection
    }
    
    /// Disconnect client from IB Gateway or Workstation
    ///
    public func disconnect() {
        guard let connection else { return }
        connection.disconnect()
        self.connection = nil
        subject.send(completion: .finished)
    }
    
    func send(encoder: IBEncoder) throws {
        guard let connection else {
            throw IBError.serverError("No connection found")
        }
        let requestDataWithLength = encoder.data.count.toBytes(size: 4) + encoder.data
        connection.send(data: requestDataWithLength)
    }
    
    
    private func didStopCallback(error: Error?) {
        subject.send(completion: .finished)
        
        if error == nil {
            exit(EXIT_SUCCESS)
        } else {
            exit(EXIT_FAILURE)
        }
    }
    
    private func stateDidChange(to state: IBConnection.State) {
        switch state {
        case .connectedToAPI:
            do {
                try self.startAPI(clientID: self.identifier)
            } catch {
                print(error)
            }
        default:
            break
        }
    }
}

public extension IBClient {
    enum ConnectionType {
        case gateway
        case workstation
        
        internal var host: String {
            "https://127.0.0.1"
        }
        
        internal var liveTradingPort: Int {
            switch self{
                case .gateway:        return 4001
                case .workstation:    return 7496
            }
        }
        
        internal var simulatedTradingPort: Int {
            switch self{
                case .gateway:        return 4002
                case .workstation:    return 7497
            }
        }
        
    }
    
    /// Creates new live trading client. All orders you send to broker, will be real and executed.
    /// - Parameter id: Master API ID, set in IB Gateway or Workstation
    /// - Parameter type: Connection type you are using.
    
    static func live(id: Int, type: ConnectionType = .gateway) -> IBClient {
        IBClient(id: id, address: type.host, port: type.liveTradingPort)
    }
    
    /// Creates new paper trading client, with simulated orders.
    /// - Parameter id: Master API ID, set in IB Gateway or Workstation
    /// - Parameter type: Connection type you are using.

    static func paper(id: Int, type: ConnectionType = .gateway) -> IBClient {
        IBClient(id: id, address: type.host, port: type.simulatedTradingPort)
    }
}
