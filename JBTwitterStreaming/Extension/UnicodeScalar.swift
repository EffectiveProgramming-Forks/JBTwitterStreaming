//
//  UnicodeScalar.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation

extension UnicodeScalar {
    var isEmoji: Bool {
        switch value {
        case 0x1D000 ... 0x1F77F: return true
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        return value == 8205
    }
}
