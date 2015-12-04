//
//  CircularArray.swift
//  SAM
//
//  Created by afilipowicz on 19.11.2015.
//  Copyright © 2015 SamLabs. All rights reserved.
//

import Foundation

public struct CircularArray<T> {
    private let array: [T]
    private var pointer = 0 {
        didSet {
            if pointer < 0 {
                pointer = array.count - 1
            }
            pointer = pointer % array.count
        }
    }
    
    public init(array: Array<T>) {
        self.array = array
    }
    
    public mutating func next() -> T {
        ++pointer
        return array[pointer]
    }
    
    public mutating func previous() -> T {
        --pointer
        return array[pointer]
    }
    
    public func current() -> T {
        return array[pointer]
    }
}
