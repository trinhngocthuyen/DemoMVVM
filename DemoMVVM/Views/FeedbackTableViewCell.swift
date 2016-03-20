//
//  FeedbackTableViewCell.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit

enum FeedbackOption {
    case Yes
    case No
    case Later
}

protocol FeedbackTableViewCellDelegate {
    func feedbackCell(cell: FeedbackTableViewCell, didChooseOption option: FeedbackOption)
}

class FeedbackTableViewCell: UITableViewCell {
    
    var delegate: FeedbackTableViewCellDelegate?
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you want to rate our app?"
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        label.textColor = UIColor(hex: 0xEEEEEE)
        return label
    }()
    
    private let yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ok, Sure", forState: .Normal)
        button.setTitleColor(UIColor(hex: 0xEEEEEE), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: 0xEEEEEE).CGColor
        return button
    }()
    
    private let noButton: UIButton = {
        let button = UIButton()
        button.setTitle("Not now", forState: .Normal)
        button.setTitleColor(UIColor(hex: 0xEEEEEE), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16, weight: UIFontWeightMedium)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: 0xEEEEEE).CGColor
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(hex: 0x6BC8C6)
        addSubview(headerLabel)
        addSubview(yesButton)
        addSubview(noButton)
        
        yesButton.addTarget(self, action: "tapButton:", forControlEvents: .TouchUpInside)
        noButton.addTarget(self, action: "tapButton:", forControlEvents: .TouchUpInside)
    }
    
    private func setupLayout() {
        headerLabel.snp_remakeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(12)
            make.left.equalTo(self).offset(12)
            make.right.equalTo(self).offset(-12)
        }
        
        noButton.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(headerLabel)
            make.top.equalTo(headerLabel.snp_bottom).offset(12)
            make.bottom.equalTo(self).offset(-12)
        }
        
        yesButton.snp_remakeConstraints { (make) -> Void in
            make.right.equalTo(headerLabel)
            make.left.equalTo(noButton.snp_right).offset(20)
            make.height.equalTo(noButton)
            make.width.equalTo(noButton)
            make.centerY.equalTo(noButton)
        }
    }
    
    func tapButton(sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        switch button {
        case yesButton:
            delegate?.feedbackCell(self, didChooseOption: .Yes)
        case noButton:
            delegate?.feedbackCell(self, didChooseOption: .No)
        case _:
            break
        }
    }
}
