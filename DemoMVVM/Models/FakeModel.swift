//
//  FakeModel.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import Foundation

class FakeModel {

    private let sampleEventNames = [
        "Revealed Vietnam Tour - Ha Noi",
        "Red Bull Champion Dash 2016",
        "The Wave Summer Hanoi 2016",
        "Triển Lãm Giáo Dục Và Định Cư Canada 2016",
        "LOGEEK Night",
        "Saigon Outcast Presents: Get Wet! Water & Music Festival",
        "[HCMC] Sungha Jung Live in Vietnam (2016)",
        "Why strategic HR matters?",
        "16th Saigon Cyclo Challenge"
    ]
    
    func generateEventName() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(sampleEventNames.count - 1)))
        return sampleEventNames[randomIndex]
    }
    
    func generateEventTime() -> NSDate {
        let randomDiffDays = Int(arc4random_uniform(20))
        return NSDate().dateByAddingTimeInterval(Double(randomDiffDays * 86400))
    }
    
    func generateEvent(capacity capacity: Int) -> [Event] {
        return (0..<capacity).map { _ in
            let event = Event()
            event.name = generateEventName()
            event.startDate = generateEventTime()
            return event
        }
    }
}