//
//  Thing.swift
//  SwiftDataWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import Foundation
import SwiftData

@Model
class Thing {
    var id: UUID = UUID()
    var name: String
    var count: Int = 1
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

extension Thing {
    static var previewThing: Thing {
        Thing(name: "Thing 1", count: 1)
    }
}
