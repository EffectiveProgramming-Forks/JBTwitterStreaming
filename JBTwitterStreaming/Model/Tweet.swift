//
//  Tweet.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation
import Swifter

fileprivate struct Entities {
    var urls = [String]()
    var hashtags: [String] = []
    var emojis: [String] = []
    var containsPhoto = false
    
    init() {
        
    }
    
    init(json: JSON) {
        if let urlsJson = json["urls"].array {
            for json in urlsJson {
                if let urlString = json["expanded_url"].string, let domain = URL(string: urlString)?.host {
                    urls.append(domain)
                }
            }
        }
        if let hashtagsJson = json["hashtags"].array {
            for json in hashtagsJson {
                if let text = json["text"].string, text != "" {
                    hashtags.append(text)
                }
            }
        }
        containsPhoto = containsPhoto(json: json)
    }
    
    func containsPhoto(json: JSON) -> Bool {
        var containsPhoto = false
        if let mediaJson = json["media"].array {
            for json in mediaJson {
                if let type = json["type"].string, type == "photo" {
                    containsPhoto = true
                    break
                }
            }
        }
        return containsPhoto
    }
}

class Tweet {
    var text: String?
    var emojis: [String] = []
    var containsEmoji: Bool {
        return !emojis.isEmpty
    }
    var urls = [String]()
    var containsUrl: Bool {
        return !urls.isEmpty
    }
    var hashtags: [String] = []
    var containsPhoto = false
    
    static func tweetWithJson(_ json: JSON) -> Tweet? {
        // don't track deleted tweets
        if json["delete"].object != nil {
            return nil
        }
        let tweet = Tweet()
        let text = json["text"].string
        if let emojis = text?.emojis, emojis.count > 0, emojis != [""] {
            tweet.emojis = emojis
        }
        if let entitiesObject = json["entities"].object {
            let entities = Entities(json: JSON(entitiesObject))
            tweet.urls = entities.urls
            tweet.hashtags = entities.hashtags
            tweet.containsPhoto = entities.containsPhoto
        }
        if !tweet.containsPhoto, let extendedEntitiesObject = json["extended_entities"].object {
            let entities = Entities()
            tweet.containsPhoto = entities.containsPhoto(json: JSON(extendedEntitiesObject))
        }
        return tweet
    }
}

