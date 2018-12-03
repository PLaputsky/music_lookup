//
//  HTTPClientQueue.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

final class HTTPClientQueue: HTTPClient {
    
    init(maxConcurrentTasks: Int, operationsBuilder: HTTPOperationsBuilder) {
        self.underlyingQueue = OperationQueue()
        self.underlyingQueue.maxConcurrentOperationCount = maxConcurrentTasks
        self.operationsBuilder = operationsBuilder
    }
    
    func performRequest(_ request: HTTPRequest) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        registerRequest(request)
    }
    
    func performRequest(_ request: HTTPRequest, completion: @escaping (HTTPResponse?) -> Void) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        registerRequest(request, completion: completion)
    }
    
    func performRequest(_ request: HTTPRequest, completion: @escaping (HTTPResponse?) -> Void, cancelClosure: ((HTTPRequest) -> Void)?) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        registerRequest(request, completion: completion, cancelClosure: cancelClosure)
    }
    
    func cancelRequest(_ request: HTTPRequest) {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        guard let operation = operations[request.udid] else {
            debugPrint("NetworkClientQueue: can't cancel request with UDID: \(request.udid)")
            return
        }
        operation.cancel()
        operations.removeValue(forKey: request.udid)
    }
    
    func cancelAll() {
        lock.lock()
        defer {
            lock.unlock()
        }
        
        operations.values.forEach { $0.cancel() }
        operations.removeAll()
    }
    
    // MARK: - Private
    
    private var operations: [String : HTTPAsyncOperation] = [:]
    private var underlyingQueue: OperationQueue
    private let lock = NSRecursiveLock()
    private var operationsBuilder: HTTPOperationsBuilder
    
    private func registerRequest(_ request: HTTPRequest, completion: ((HTTPResponse?) -> Void)? = nil, cancelClosure: ((HTTPRequest) -> Void)? = nil) {
        let httpOperation = operationsBuilder.operation(for: request) { response in
            request.isCancelled ? cancelClosure?(request) : completion?(response)
        }
        
        httpOperation.completionBlock = { [weak self] in
            self?.unregisterRequest(request)
        }
        operations[request.udid] = httpOperation
        underlyingQueue.addOperation(httpOperation)
    }
    
    private func unregisterRequest(_ request: HTTPRequest) {
        lock.lock()
        defer {
            lock.unlock()
        }
        operations.removeValue(forKey: request.udid)
    }
}
