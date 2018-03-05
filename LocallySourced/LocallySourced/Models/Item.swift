//
//  Item.swift
//  LocallySourced
//
//  Created by C4Q on 3/3/18.
//  Copyright © 2018 TeamLocallySourced. All rights reserved.
//

import Foundation
class Item: Codable {
    let name: String
    var amount: Double
    var completed: Bool
    init(name: String, amount: Double, completed: Bool) {
        self.name = name
        self.amount = amount
        self.completed = completed
    }
}
