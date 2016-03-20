//
//  SecondViewControllers.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/20/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

class SecondViewController: UIViewController {
    private struct Identifier {
        static let EventItemCell = "EventItemCell"
        static let FeedbackCell = "FeedbackCell"
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
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
            make.top.equalTo(self.view.snp_top).offset(64)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.bottom.equalTo(self.view.snp_bottom)
        }
    }
    
}

extension SecondViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.EventItemCell) as! EventItemTableViewCell
        
        let fakeModel = FakeModel()
        
        cell.name = fakeModel.generateEventName()
        cell.time = fakeModel.generateEventTime()
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
}
