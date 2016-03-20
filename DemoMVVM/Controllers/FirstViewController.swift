//
//  FirstViewController.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/20/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

class FirstViewController: UIViewController {
    // MARK: - Constants
    private struct Constants {
        static let FeedbackIndex = 3
    }
    
    private struct Identifier {
        static let EventItemCell = "EventItemCell"
        static let FeedbackCell = "FeedbackCell"
    }
    
    // MARK: - Subclasses
    private enum DataItem {
        case EventItem(Event)
        case FeedbackItem
    }
    
    // MARK: - Views
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    // MARK: - Data
    private var events: [Event] = FakeModel().generateEvent(capacity: 50)
    private var shouldShowFeedbackCell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
    }
    
    func setupView() {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.registerClass(EventItemTableViewCell.self, forCellReuseIdentifier: Identifier.EventItemCell)
        tableView.registerClass(FeedbackTableViewCell.self, forCellReuseIdentifier: Identifier.FeedbackCell)
    }
    
    func setupLayout() {
        tableView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }
}

extension FirstViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowFeedbackCell {
            return events.count + 1
        }
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataItem = dataItemAtIndex(indexPath.row)
        switch dataItem {
        case .EventItem(let event):
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.EventItemCell) as! EventItemTableViewCell
            configureCell(cell, withEvent: event)
            return cell
            
        case .FeedbackItem:
            let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.FeedbackCell) as! FeedbackTableViewCell
            configureCell(cell)
            return cell
        }
    }
    
    private func dataItemAtIndex(index: Int) -> DataItem {
        if !shouldShowFeedbackCell {
            return .EventItem(events[index])
        }
        
        if index == Constants.FeedbackIndex {
            return .FeedbackItem
        } else if index < Constants.FeedbackIndex {
            return .EventItem(events[index])
        } else {
            return .EventItem(events[index + 1])
        }
    }
    
    private func configureCell(cell: EventItemTableViewCell, withEvent event: Event) {
        cell.name = event.name
        cell.time = event.startDate
        cell.layoutIfNeeded()
    }
    
    private func configureCell(cell: FeedbackTableViewCell) {
        cell.delegate = self
        cell.layoutIfNeeded()
    }
    
}

extension FirstViewController: FeedbackTableViewCellDelegate {
    func feedbackCell(cell: FeedbackTableViewCell, didChooseOption option: FeedbackOption) {
        collapseFeedbackCell()
    }
    
    private func collapseFeedbackCell() {
        shouldShowFeedbackCell = false
        let indexPath = NSIndexPath(forRow: Constants.FeedbackIndex, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
    }
}
