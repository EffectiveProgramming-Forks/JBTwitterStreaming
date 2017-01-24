//
//  Metrics.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation

struct Metrics {
    private var didUpdate = false // don't update display metrics if metrics weren't updated
    
    // Hashtags
    var hashtags = [String: UInt]()
    
    // Emojis
    var emojis = [String: UInt]()
    var containsEmojiCount: UInt = 0
    
    // Urls
    var domains = [String: UInt]()
    var containsUrlCount: UInt = 0
    
    // Photos
    var containsPhotoCount: UInt = 0
    var tweetCount: UInt = 0
    
    //MARK: Update metrics
    
    mutating func update(tweet: Tweet) {
        tweetCount += 1
        update(entityDictionary: &emojis, with: tweet.emojis)
        update(entityDictionary: &hashtags, with: tweet.hashtags)
        update(entityDictionary: &domains, with: tweet.urls)
        if tweet.containsUrl {
            containsUrlCount += 1
        }
        if tweet.containsPhoto {
            containsPhotoCount += 1
        }
        if tweet.containsEmoji {
            containsEmojiCount += 1
        }
        didUpdate = true
    }
    
    private func update(entityDictionary dictionary: inout [String: UInt], with array: [String]) {
        for value in array {
            if let count = dictionary[value] {
                dictionary[value] = count + 1
            } else {
                dictionary[value] = 1
            }
        }
    }
    
    //MARK: Get display metrics
    
    mutating func getDisplayMetrics(startDate: Date?) -> DisplayMetrics? {
        if didUpdate == false {
            return nil
        }
        let numberOfSeconds = getNumberOfSecondsElapsed(startDate: startDate)
        var displayMetrics = DisplayMetrics(metrics: self, numberOfSeconds: numberOfSeconds)
        displayMetrics.topHashtags = sort(dictionary: hashtags)
        displayMetrics.topEmojis = sort(dictionary: emojis)
        displayMetrics.topDomains = sort(dictionary: domains)
        didUpdate = false
        return displayMetrics
    }
    
    private func getNumberOfSecondsElapsed(startDate: Date?) -> UInt {
        var numberOfSeconds: UInt = 0
        if let startDate = startDate {
            numberOfSeconds = UInt(startDate.secondsSinceDate)
        }
        return numberOfSeconds
    }
    
    private func sort(dictionary: [String: UInt]) -> [TopValue] {
        let sortedArray = dictionary.sorted { $0.value > $1.value }
        return Array(sortedArray.prefix(Constant.TwitterStream.maxTopValuesToDisplay)) as! [TopValue]
    }
}
