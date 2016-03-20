//
//  ItemTableViewCell.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit

class EventItemTableViewCell: UITableViewCell {
    
    // MARK: - Views
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12, weight: UIFontWeightSemibold)
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10, weight: UIFontWeightRegular)
        return label
    }()

    // MARK: - Models
    var name: String = "" {
        didSet { nameLabel.text = name }
    }
    var time: NSDate = NSDate() {
        didSet { timeLabel.text = time.toStringWithFormat("dd/MM/yyyy") }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        addSubview(nameLabel)
        addSubview(timeLabel)
    }
    
    func setupLayout() {
        nameLabel.snp_remakeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top).offset(8)
            make.left.equalTo(self.snp_left).offset(12)
            make.right.equalTo(self.snp_right).offset(12)
        }
        
        timeLabel.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(self.nameLabel.snp_left)
            make.right.equalTo(self.nameLabel.snp_right)
            make.top.equalTo(self.nameLabel.snp_bottom).offset(8)
            make.bottom.equalTo(self.snp_bottom).offset(-8)
        }
    }

}
