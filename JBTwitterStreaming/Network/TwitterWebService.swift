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
        let consumerKey = "aVThC4Adafl2fMQdnMVTdPGnS"
        let consumerSecret = "tpsDI7XfHryBRSwYEFugHWhKwfEKtixPy8bwVvvwpBDE6vtchc"
        let accessToken = "242103298-ewSaidq24kC7Muu5jshDNu57Rsmts4jk3qjF4GuY"
        let accessTokenSecret = "9xtE7ChuJhQMTBZgoRSjPHVMbRXJgbvD3iSKFgvkBmcRQ"
        let swifter: Swifter = Swifter(consumerKey: consumerKey,
                                       consumerSecret: consumerSecret,
                                       oauthToken: accessToken,
                                       oauthTokenSecret: accessTokenSecret)
        streamRequest = swifter.streamRandomSampleTweets(delimited: true, stallWarnings: true, progress: { (json: JSON) in
            if let tweet = Tweet.tweetWithJson(json) {
                DispatchQueue.global().async {
                    self.metrics?.update(tweet: tweet)
                }
            }
            }, stallWarningHandler: { (_ code: String?, _ message: String?, _ percentFull: Int?) in
                if let code = code, let message = message {
                    print("Stall warning code: \(code) message: \(message)")
                }
        }) { (error: Error) in
            let cancelledCode = -999
            if (error as NSError).code != cancelledCode {
                self.delegate?.failedToLoadTweets(errorMessage: error.localizedDescription)
                self.stopDisplayMetricsTimer()
            }
        }
    }
    
    //MARK: Update Display Metrics Timer
    
    private func updateDisplayMetrics() {
        if let displayMetrics = metrics?.getDisplayMetrics(startDate: startDate) {
            DispatchQueue.main.async {
                self.delegate?.didLoadTweets(metrics: displayMetrics)
            }
        }
    }
    
    private func addUpdateDisplayMetricsTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: Constant.TwitterStream.updateDisplayMetricsInterval, repeats: true) { (timer: Timer) in
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).sync {
                self.updateDisplayMetrics()
            }
        }
    }
    
    private func stopDisplayMetricsTimer() {
        timer?.invalidate()
        timer = nil
    }
}


