//
//  Date.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation

extension Date {
    var secondsSinceDate: Double {
        return Date().timeIntervalSince(self)
    }
}
