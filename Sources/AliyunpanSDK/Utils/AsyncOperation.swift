//
//  AsyncOperation.swift
//  AliyunpanSDK
//
//  Created by zhaixian on 2023/12/19.
//

import Foundation

class AsyncOperation: Operation {
    @objc enum State: Int {
        case ready
        case executing
        case finished
        case cancel
    }
    
    @ThreadSafe
    @objc var state: State = .ready {
        willSet {
            willChangeValue(for: \.isReady)
            willChangeValue(for: \.isExecuting)
            willChangeValue(for: \.isFinished)
            willChangeValue(for: \.isCancelled)
        }
        didSet {
            didChangeValue(for: \.isReady)
            didChangeValue(for: \.isExecuting)
            didChangeValue(for: \.isFinished)
            didChangeValue(for: \.isCancelled)
            
            updateState(state: state, oldValue: oldValue)
        }
    }
    
    override var isAsynchronous: Bool {
        true
    }
    
    override var isReady: Bool {
        state == .ready && super.isReady
    }
    
    override var isExecuting: Bool {
        state == .executing
    }
    
    override var isFinished: Bool {
        state == .finished || state == .cancel
    }
    
    override var isCancelled: Bool {
        state == .cancel
    }
    
    override func start() {
        guard !isCancelled else {
            cancel()
            return
        }
        
        state = .executing
        
        main()
    }
    
    func finish() {
        state = .finished
    }
    
    override func cancel() {
        state = .cancel
    }
    
    func updateState(state: State, oldValue: State) {}
}

class AsyncThrowOperation<Success, Failure: Error>: AsyncOperation {
    var result: Result<Success, Failure>?
}
