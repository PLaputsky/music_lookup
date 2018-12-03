//
//  AsyncOperation.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    enum OperationState: String {
        case ready, executing, finished
        
        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
    
    var state: OperationState  = .ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    // NSOperation Lifecycle
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override func main() {
        
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            completionBlock?()
            return
        }
        
        main()
        state = .executing
    }
    
    override func cancel() {
        super.cancel()
        state = .finished
    }
}

