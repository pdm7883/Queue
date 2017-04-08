//
//  QueueModel.swift
//  Queue
//
//  Created by bell on 4/5/17.
//  Copyright © 2017 Mukunda Dhirendrachar. All rights reserved.
//

import Foundation

protocol QueueProtocol : class {
    func handleUpdatedItems(items: [String])
    var queuename : String {get set}
}

struct Queue {
    fileprivate var items : Array<String>
    let name = NSNotification.Name("QUEUE_COUNT_UPDATED")
    weak var delegate: QueueProtocol?
    
    var count : Int {
        return items.count
    }

    var isEmpty : Bool {
        return items.isEmpty
    }
    
    mutating func enqueue(item: String) {
        self.items.append(item)
        notifyCaller()
    }
    
    func display () {
//        print("Queue items: \(self.items)")
    }
    
    private func notifyCaller() {
        // 1. Notify observers
        NotificationCenter.default.post(name: name, object: nil, userInfo: ["items": items])
        
        // 2. Notify delegates
        delegate?.handleUpdatedItems(items: items)
    }
    
    mutating func dequeue() -> String? {
        if isEmpty == false {
            let removedItem = self.items.removeFirst()
            notifyCaller()
            return removedItem
        }
        
        return nil
    }
    
    init() {
        self.items = [String]()
    }
}
