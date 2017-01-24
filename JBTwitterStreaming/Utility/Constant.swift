//
//  Constant.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import UIKit

struct Constant {
    struct TableView {
        static let headerHeight: CGFloat = 44
        static let minimumNumberOfRowsInSection: Int = 1
        
        struct CellIdentifier {
            static let value1Style = "value1Style"
        }
    }
    
    struct TwitterStream {
        static let updateDisplayMetricsInterval: TimeInterval = 0.3
        static let maxTopValuesToDisplay: Int = 10
    }
    
    struct Time {
        static let secondsInMinute: UInt = 60
        static let minutesInHour: UInt = 60
    }
    
    struct Notification {
        static let applicationDidEnterBackground = "applicationDidEnterBackground"
        static let applicationWillEnterForeground = "applicationWillEnterForeground"
    }
    
    struct Authentication {
        static let consumerKey = "++T29RSBmvhXZITx/dGEvSHc1rBSVNjCYUmyVSSoD+Y="
        static let consumerSecret = "UJv/NLI+6Rb5QnGsoCyY4uuwMrvDgk5KRwLd627UW/CtwHtsXTpSHwdSXiQRSgM9pmcHenNHPnMoo5LSz3gs0A=="
        static let accessToken = "kVFdTUr1XwmF8af1IhHuQTJmBW2yvn7KgkAQjgo+9ey4bH5AWVqOz/g35HwnmMIilT+fw0BpHoEQROdRPIHZmw=="
        static let accessTokenSecret = "EAP+HHKI5iMTu96oUXkn5MxXrfucorPXm0Hvwo6M+BsMdHpuXR1JwpXvckWghAib"
        static let key = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"
        static let iv = "gqLOHUioQ0QjhuvI"
    }
}
