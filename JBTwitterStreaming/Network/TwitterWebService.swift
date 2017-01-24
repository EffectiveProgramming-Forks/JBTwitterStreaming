//
//  TwitterWebService.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import Foundation
import Swifter

protocol TwitterWebServiceDelegate: class {
    func didLoadTweets(metrics: DisplayMetrics?)
    func failedToLoadTweets(errorMessage: String)
}

class TwitterWebService {
    weak var delegate: TwitterWebServiceDelegate?
    private var streamRequest: HTTPRequest?
    private var metrics: Metrics?
    private var startDate: Date?
    private var timer: Timer?
    private let queue = DispatchQueue(label: "com.twitterstreaming.serialqueue", attributes: .concurrent)
    init(delegate: TwitterWebServiceDelegate?) {
        self.delegate = delegate
    }
    
    func stopStreaming() {
        streamRequest?.stop()
        stopDisplayMetricsTimer()
        metrics = nil
    }
    
    func startStreaming() {
        metrics = Metrics()
        addUpdateDisplayMetricsTimer()
        startDate = Date()
        // Application access level: read-only
        // Not safe - don't store authentication values in prod
        let swifter: Swifter = Swifter(consumerKey: try! Constant.Authentication.consumerKey.decrypt(
            key: Constant.Authentication.key, iv: Constant.Authentication.iv),
                                       consumerSecret: try! Constant.Authentication.consumerSecret.decrypt(
                                        key: Constant.Authentication.key, iv: Constant.Authentication.iv),
                                       oauthToken: try! Constant.Authentication.accessToken.decrypt(
                                        key: Constant.Authentication.key, iv: Constant.Authentication.iv),
                                       oauthTokenSecret: try! Constant.Authentication.accessTokenSecret.decrypt(
                                        key: Constant.Authentication.key, iv: Constant.Authentication.iv))
        streamRequest = swifter.streamRandomSampleTweets(delimited: true, stallWarnings: true, progress: { [weak self] (json: JSON) in
            if let tweet = Tweet.tweetWithJson(json) {
                DispatchQueue.global().async {
                    self?.metrics?.update(tweet: tweet)
                }
            }
            }, stallWarningHandler: { (_ code: String?, _ message: String?, _ percentFull: Int?) in
                if let code = code, let message = message {
                    print("Stall warning code: \(code) message: \(message)")
                }
        }) { [weak self] (error: Error) in
            let cancelledCode = -999
            if (error as NSError).code != cancelledCode {
                self?.delegate?.failedToLoadTweets(errorMessage: error.localizedDescription)
                self?.stopDisplayMetricsTimer()
            }
        }
    }

    //MARK: Update Display Metrics Timer
    
    private func updateDisplayMetrics() {
        guard let metrics = self.metrics, metrics.shouldUpdateDisplayMetrics == true else {
            return
        }
        var displayMetrics = DisplayMetrics(metrics: metrics)
        let group = DispatchGroup()
        
        queue.async (group: group) {
            displayMetrics.topHashtags = metrics.sort(dictionary: metrics.hashtags)
        }
        
        queue.async (group: group) {
            displayMetrics.topEmojis = metrics.sort(dictionary: metrics.emojis)
        }
        
        queue.async (group: group) {
            displayMetrics.topDomains = metrics.sort(dictionary: metrics.domains)
        }
        queue.async (group: group) {
            if let startDate = self.startDate {
                displayMetrics.numberOfSeconds = UInt(startDate.secondsSinceDate)
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.metrics?.didUpdateDisplayMetrics()
            self.delegate?.didLoadTweets(metrics: displayMetrics)
        }
    }
    
    private func addUpdateDisplayMetricsTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Constant.TwitterStream.updateDisplayMetricsInterval, repeats: true) { [weak self] (timer: Timer) in
            DispatchQueue.global().async {
                self?.updateDisplayMetrics()
            }
        }
    }
    
    private func stopDisplayMetricsTimer() {
        timer?.invalidate()
        timer = nil
    }
}


