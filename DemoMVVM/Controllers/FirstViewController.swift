//
//  FirstViewController.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/20/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

class FirstViewController: SharedViewController {
    // MARK: - Data
    var events: [Event] = []
    private var shouldShowFeedbackCell = true
    private var isLoadingMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        updateData()
    }
    
}

// MARK: - Data
extension FirstViewController {
    
    private func updateData() {
        let fetchDataTask = FetchDataTask()
        fetchDataTask.fetchDataFromLocal().takeUntilReplacement(fetchDataTask.fetchDataFromServer())
            .on(next: { events in
                self.events = events
                self.tableView.reloadData()
            })
            .on(failed: { error in
                NSLog("Error: \(error.description)")
            })
            .start()
    }
    
    private func loadMoreDataAndReloadView(completion: Void -> Void) {
        let fetchDataTask = FetchDataTask()
        fetchDataTask.fetchDataFromServer()
            .on(next: { newEvents in
                self.events += newEvents
                self.tableView.reloadData()
            })
            .on(failed: { error in
                NSLog("Error: \(error.description)")
            })
            .on(completed: completion)
            .start()
    }
}

// MARK: - UITableViewDataSource
extension FirstViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowFeedbackCell && events.count >= Constants.FeedbackIndex {
            return events.count + 1
        }
        return events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataItem = dataItemAtIndex(indexPath.row)
        switch dataItem {
        case .EventItem(let event):
            // swiftlint:disable force_cast
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
            return .EventItem(events[index - 1])
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

// MARK: - UITableViewDelegate
extension FirstViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height)) {
            // Only load more if the previous invoke of loading more has completed
            if !isLoadingMore {
                // Show loading & lock load-more
                isLoadingMore = true
                animateLoadingMore(true)
                
                loadMoreDataAndReloadView {
                    // Hide loading & Freeze load-more
                    self.isLoadingMore = false
                    self.animateLoadingMore(false)
                }
            }
        }
    }
}

// MARK: - FeedbackTableViewCellDelegate
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

