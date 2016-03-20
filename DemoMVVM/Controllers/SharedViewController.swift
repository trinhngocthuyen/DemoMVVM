//
//  SharedViewController.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/31/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

// MARK: - Constants
struct Constants {
    static let FeedbackIndex = 3
    static let NumberOfItemsToLoadMore = 15
}

class SharedViewController: UIViewController {
    struct Identifier {
        static let EventItemCell = "EventItemCell"
        static let FeedbackCell = "FeedbackCell"
    }
    
    // MARK: - Views
    let tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    let loadingView: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hex: 0x6BC8C6)
        label.text = "Loading more..."
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
        label.textColor = UIColor(hex: 0xF8F8F8)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        view.addSubview(loadingView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.registerClass(EventItemTableViewCell.self, forCellReuseIdentifier: Identifier.EventItemCell)
        tableView.registerClass(FeedbackTableViewCell.self, forCellReuseIdentifier: Identifier.FeedbackCell)
    }
    
    private func setupLayout() {
        tableView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
        loadingView.snp_remakeConstraints { (make) in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(view).offset(44)
            make.height.equalTo(44)
        }
    }
    
    func animateLoadingMore(shouldShow: Bool) {
        if shouldShow {
            loadingView.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(0)
            })
            UIView.animateWithDuration(0.25) { self.view.layoutIfNeeded() }
        } else {
            loadingView.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(view).offset(44)
            })
        }
    }
    
    func moveALittleUpper() {
        // Move table view a little upper
        let newContentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + 20)
        self.tableView.setContentOffset(newContentOffset, animated: true)
    }
}