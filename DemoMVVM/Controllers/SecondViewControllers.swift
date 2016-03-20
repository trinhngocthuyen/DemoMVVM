//
//  SecondViewControllers.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/20/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

class SecondViewController: SharedViewController {
    
    // MARK: - Data
    private var viewModel = EventsViewModel(fetchDataTask: FetchDataTask())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupRAC()
    }
    
    private func setupRAC() {
        // Fetch from local & fetch from server
        viewModel.fetchDataFromLocal().takeUntilReplacement(viewModel.fetchDataFromServer())
            .on(next: { _ in
                self.tableView.reloadData()
            })
            .on(failed: { error in
                NSLog("Error: \(error.description)")
            })
            .start()
        
        // Animate loading more based on the state of isLoadingMore
        viewModel.isLoadingMore.producer
            .on(next: self.animateLoadingMore )
            .start()
    }
    
    func injected() {
        NSLog("Injected from SecondViewController")
        
    }
}

extension SecondViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfDataItems()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataItem = viewModel.dataItemAtIndex(indexPath.row)
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

extension SecondViewController: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height)) {
            viewModel.fetchMoreData()
                .on(next: { newEvents in
                    self.tableView.reloadData()
                    if !newEvents.isEmpty {
                        self.moveALittleUpper()
                    }
                })
                .start()
        }
    }
}

extension SecondViewController: FeedbackTableViewCellDelegate {
    
    func feedbackCell(cell: FeedbackTableViewCell, didChooseOption option: FeedbackOption) {
        collapseFeedbackCell()
    }
    
    private func collapseFeedbackCell() {
        viewModel.shouldShowFeedbackCell = false
        let indexPath = NSIndexPath(forRow: Constants.FeedbackIndex, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
    }
}
