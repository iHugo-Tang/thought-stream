//
//  Item.swift
//  ThoughtStream
//
//  Created by Hugo L on 2025-08-30.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
