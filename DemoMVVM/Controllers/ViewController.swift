//
//  ViewController.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let tableView: UITableView = UITableView()
    private var vcCreators: [(title: String, vc: () -> UIViewController)] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        
        vcCreators = [
            (title: "MVC Implementation", { FirstViewController() }),
            (title: "MVVM Implementation", { SecondViewController() })]
    }
    
    func setupView() {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupLayout() {
        tableView.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcCreators.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = vcCreators[indexPath.row].title
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = vcCreators[indexPath.row].vc()
        navigationController?.pushViewController(vc, animated: true)
    }
}

