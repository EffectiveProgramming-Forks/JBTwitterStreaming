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
    private var webservice: TwitterWebService?
    
    /*
     Designated Initializer
     */
    init() {
        super.init(nibName: nil, bundle: nil)
        addObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Observers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.Notification.applicationWillEnterForeground), object: nil, queue: nil) { [weak self] (notification) in
            self?.startStreaming()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground), object: nil, queue: nil) { [weak self] (notification) in
            self?.stopStreaming()
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: Constant.Notification.applicationWillEnterForeground),
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: Constant.Notification.applicationDidEnterBackground),
                                                  object: nil)
    }

    //MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Twitter stream sample"
        addRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startStreaming()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopStreaming()
    }
    
    deinit {
        removeObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        refreshStream()
    }
    
    //MARK: Load Data
    
    private func startStreaming() {
        stopStreaming()
        tableView.reloadData()
        webservice = TwitterWebService(delegate: self)
        webservice?.startStreaming()
    }
    
    private func stopStreaming() {
        webservice?.stopStreaming()
        webservice = nil
        metrics = nil
    }
    
    //MARK: Refresh
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self,
                                  action: #selector(refreshStream(control:)),
                                  for: UIControlEvents.valueChanged)
    }
    
    func refreshStream(control: UIRefreshControl?) {
        control?.endRefreshing()
        refreshStream()
    }
    
    private func refreshStream() {
        startStreaming()
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
    
    func failedToLoadTweets(errorMessage: String) {
        let alertController = UIAlertController(title: "Error!",
                                                message: errorMessage,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        stopStreaming()
    }
}

fileprivate enum Section {
    case metrics
    case hashtags
    case domains
    case emojis
    
    func getNumberOfRows(_ metrics: DisplayMetrics?) -> Int {
        switch self {
        case .metrics: return metrics != nil ? Metric.allRows.count : Constant.TableView.minimumNumberOfRowsInSection
        case .hashtags: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topHashtags.count)
        case .domains: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topDomains.count)
        case .emojis: return getNumberOfTopValuesToDisplay(entityCount: metrics?.topEmojis.count)
        }
    }
    
    private func getNumberOfTopValuesToDisplay(entityCount: Int?) -> Int {
        if let entityCount = entityCount, entityCount > Constant.TableView.minimumNumberOfRowsInSection {
            return entityCount
        } else {
            return Constant.TableView.minimumNumberOfRowsInSection
        }
    }
    
    func getDisplayValue(index: Int, metrics: DisplayMetrics?) -> TopValue? {
        guard let metrics = metrics else {
            return nil
        }
        switch self {
        case .metrics:
            return Metric.allRows[index].getDisplayValue(metrics)
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
            case .percentContainUrl: return ("Percent tweets contain a url", metrics.percentContainUrl)
            case .percentContainEmoji: return ("Percent tweets contain an emoji", metrics.percentContainEmoji)
            case .percentContainPhoto: return ("Percent tweets contain a photo", metrics.percentContainPhoto)
            }
        }
        
        static var allRows: [Metric] {
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

