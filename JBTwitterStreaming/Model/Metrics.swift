//
//  Metrics.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation

struct Metrics {
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
    
    func getDisplayMetrics(numberOfSeconds: UInt) -> DisplayMetrics {
        var displayMetrics = DisplayMetrics(metrics: self, numberOfSeconds: numberOfSeconds)
        displayMetrics.topHashtags = sort(dictionary: hashtags)
        displayMetrics.topEmojis = sort(dictionary: emojis)
        displayMetrics.topDomains = sort(dictionary: domains)
        return displayMetrics
    }
    
    func sort(dictionary: [String: UInt]) -> [TopValue] {
        let sortedArray = dictionary.sorted { $0.1 > $1.1 }
        return Array(sortedArray.prefix(10)) as! [TopValue]
    }
    
    func bucketSort(dictionary: [String: UInt]) -> [[String]] {
        var sortedArray: [[String]]?
        if let arraySize = dictionary.values.max() {
            var array = [[String]](repeating: [""], count: Int(arraySize + 1))
            for (key, value) in dictionary {
                var values: [String] = array[Int(value)]
                values.append(key)
                array[Int(value)] = values
            }
            sortedArray = array
        }
        return sortedArray ?? [[]]
    }
    
    private func update(array: [String], dictionary: inout [String: UInt]) {
        for value in array {
            if let count = dictionary[value] {
                dictionary[value] = count + 1
            } else {
                dictionary[value] = 1
            }
        }
    }
    
    mutating func update(tweet: Tweet) {
        tweetCount += 1
        update(array: tweet.emojis, dictionary: &emojis)
        update(array: tweet.hashtags, dictionary: &hashtags)
        update(array: tweet.urls, dictionary: &domains)
        if tweet.containsUrl {
            containsUrlCount += 1
        }
        if tweet.containsPhoto {
            containsPhotoCount += 1
        }
        if tweet.containsEmoji {
            containsEmojiCount += 1
        }
    }
}
