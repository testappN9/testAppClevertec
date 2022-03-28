//
//  Box.swift
//  testAppClevertec
//
//  Created by Apple on 26.03.22.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
        //listener(value)
    }
}

enum AlertType {
    case noConnection, deleteItem
}
