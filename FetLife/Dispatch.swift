//
//  Dispatch.swift
//  FetLife
//
//  Created by Jose Cortinas on 3/7/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import Foundation

typealias ExecutionBlock = () -> Void
typealias DispatchQueue = dispatch_queue_t

struct Dispatch {
    static func asyncOnMainQueue(asyncBlock: ExecutionBlock) {
        executeAsynchronously(Queue.main, closure: asyncBlock)
    }
    
    static func asyncOnUserInitiatedQueue(asyncBlock: ExecutionBlock) {
        executeAsynchronously(Queue.userInitiated, closure: asyncBlock)
    }
    
    static func asyncOnUtilityQueue(asyncBlock: ExecutionBlock) {
        executeAsynchronously(Queue.utility, closure: asyncBlock)
    }
    
    static func asyncOnBackgroundQueue(asyncBlock: ExecutionBlock) {
        executeAsynchronously(Queue.background, closure: asyncBlock)
    }
    
    static func executeAsynchronously(serviceQueue: DispatchQueue, closure: ExecutionBlock) {
        dispatch_async(serviceQueue, closure)
    }
    
    struct Queue {
        static var main: DispatchQueue {
            return dispatch_get_main_queue()
        }
        
        static var userInitiated: DispatchQueue {
            return getGlobalQueueById(qosLevel: QOS_CLASS_USER_INITIATED)
        }
        
        static var utility: DispatchQueue {
            return getGlobalQueueById(qosLevel: QOS_CLASS_UTILITY)
        }
        
        static var background: DispatchQueue {
            return getGlobalQueueById(qosLevel: QOS_CLASS_BACKGROUND)
        }
        
        static func getGlobalQueueById(qosLevel id: qos_class_t, flags: UInt = 0) -> DispatchQueue {
            return dispatch_get_global_queue(id, flags)
        }
    }
}