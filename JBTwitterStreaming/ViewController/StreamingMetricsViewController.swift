//
//  StreamingMetricsViewController.swift
//  JBTwitterStreaming
//
//  Created by Jeff Breunig on 1/23/17.
//  Copyright © 2017 Jeff Breunig. All rights reserved.
//

import UIKit

class StreamingMetricsViewController: UITableViewController, TwitterWebServiceDelegate {
    private var metrics: DisplayMetrics?
    
    //MARK: View lifecycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter stream sample"
        loadData()
    }
    
    private func loadData() {
        let webservice = TwitterWebService(delegate: self)
        webservice.getTweets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TableView Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allSections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allSections[section].getNumberOfRows(metrics)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.TableView.CellIdentifier.value1Style) ??
            UITableViewCell.init(style: .value1, reuseIdentifier: Constant.TableView.CellIdentifier.value1Style)
        let topValue = Section.allSections[indexPath.section].getDisplayValue(index: indexPath.row, metrics: metrics)
        cell.textLabel?.text = topValue?.title ?? "No data"
        if let value = topValue?.value {
            cell.detailTextLabel?.text = "\(value)"
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section.allSections[section].heightForHeader
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section.allSections[section].titleForHeader
    }
    
    //MARK: TwitterWebServiceDelegate {
    
    func didLoadTweets(metrics: DisplayMetrics?) {
        self.metrics = metrics
        tableView.reloadData()
    }
    
    func failedToLoadTweets(errorMessage: String?) {
        
    }
}

fileprivate enum Section {
    case metrics
    case hashtags
    case domains
    case emojis
    
    func getNumberOfRows(_ metrics: DisplayMetrics?) -> Int {
        switch self {
        case .metrics: return Metric.allSections.count
        case .hashtags: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topHashtags.count)
        case .domains: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topDomains.count)
        case .emojis: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topEmojis.count)
        }
    }
    
    private func getNumberOfTopValuesToDisplay(entityCount: Int?) -> Int {
        return entityCount ?? Constant.TableView.minimumNumberOfRowsInSection
    }
    
    func getDisplayValue(index: Int, metrics: DisplayMetrics?) -> TopValue? {
        guard let metrics = metrics else {
            return nil
        }
        switch self {
        case .metrics:
            return Metric.allSections[index].getDisplayValue(metrics)
        case .hashtags:
            return getDisplayValue(index: index, topValue: metrics.topHashtags)
        case .domains:
            return getDisplayValue(index: index, topValue: metrics.topDomains)
        case .emojis:
            return getDisplayValue(index: index, topValue: metrics.topEmojis)
        }
    }
    
    private func getDisplayValue(index: Int, topValue: [TopValue]) -> TopValue? {
        return topValue.count > index ? topValue[index] : nil
    }
    
    var heightForHeader: CGFloat {
        return Constant.TableView.headerHeight
    }
    
    var titleForHeader: String {
        switch self {
        case .metrics: return "Metrics"
        case .hashtags: return "Top hashtags"
        case .domains: return "Top domains"
        case .emojis: return "Top emojis"
        }
    }
    
    static var allSections: [Section] {
        return [.metrics, .hashtags, .domains, .emojis]
    }
    
    enum Metric {
        case tweetCount
        case tweetsPerHour
        case tweetsPerMinute
        case tweetsPerSecond
        case percentContainUrl
        case percentContainEmoji
        case percentContainPhoto
        
        func getDisplayValue(_ metrics: DisplayMetrics) -> TopValue? {
            switch self {
            case .tweetCount: return ("Tweet count", metrics.tweetCount)
            case .tweetsPerHour: return ("Tweets per hour", metrics.tweetsPerHour)
            case .tweetsPerMinute: return ("Tweets per minute", metrics.tweetsPerMinute)
            case .tweetsPerSecond: return ("Tweets per second", metrics.tweetsPerSecond)
            case .percentContainUrl: return ("Percent contain a url", metrics.percentContainUrl)
            case .percentContainEmoji: return ("Percent contain an emoji", metrics.percentContainEmoji)
            case .percentContainPhoto: return ("Percent contain a photo", metrics.percentContainPhoto)
            }
        }
        
        static var allSections: [Metric] {
            return [.tweetCount,
                    .tweetsPerHour,
                    .tweetsPerMinute,
                    .tweetsPerSecond,
                    .percentContainUrl,
                    .percentContainEmoji,
                    .percentContainPhoto]
        }
    }
}

