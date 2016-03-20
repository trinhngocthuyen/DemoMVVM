//
//  Extensions.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import UIKit

extension NSDate {
    func toStringWithFormat(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension UIColor {
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: a)
    }
    
    public convenience init(hex: Int, a: CGFloat = 1.0) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
}
