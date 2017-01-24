//
//  DisplayMetrics.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation

typealias TopValue = (title: String, value: UInt)

struct DisplayMetrics {
    // Hashtags
    var topHashtags = [TopValue]()
    
    // Emojis
    var topEmojis = [TopValue]()
    var containsEmojiCount: UInt = 0
    var percentContainEmoji: UInt {
        return getPercentTweetsContainingEntity(entityCount: containsEmojiCount)
    }
    
    // Urls
    var topDomains = [TopValue]()
    var containsUrlCount: UInt = 0
    var percentContainUrl: UInt {
        return getPercentTweetsContainingEntity(entityCount: containsUrlCount)
    }
    
    // Photos
    var containsPhotoCount: UInt = 0
    var percentContainPhoto: UInt {
        return getPercentTweetsContainingEntity(entityCount: containsPhotoCount)
    }
    
    // Metrics
    private var numberOfSeconds: UInt = 0
    var tweetCount: UInt = 0
    var tweetsPerHour: UInt {
        return tweetsPerMinute * Constant.Time.minutesInHour
    }
    var tweetsPerMinute: UInt {
        return tweetsPerSecond * Constant.Time.secondsInMinute
    }
    var tweetsPerSecond: UInt {
        return numberOfSeconds > 0 ? tweetCount / numberOfSeconds : 0
    }
    
    /*
     Designated Initializer
     */
    init(metrics: Metrics, numberOfSeconds: UInt) {
        tweetCount = metrics.tweetCount
        containsEmojiCount = metrics.containsEmojiCount
        containsUrlCount = metrics.containsUrlCount
        containsPhotoCount = metrics.containsPhotoCount
        self.numberOfSeconds = numberOfSeconds
    }
    
    private func getPercentTweetsContainingEntity(entityCount: UInt) -> UInt {
        return tweetCount > 0 ? UInt(Double(entityCount) / Double(tweetCount) * 100) : 0
    }
}
