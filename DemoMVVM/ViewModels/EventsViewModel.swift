//
//  EventsViewModel.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/16/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

struct APIError {
    static let BadRequest = NSError(domain: "thuyen.demomvvm", code: 500, userInfo: nil)
    static let RequestTimeout = NSError(domain: "thuyen.demomvvm", code: 408, userInfo: nil)
    static let InternalServerError = NSError(domain: "thuyen.demomvvm", code: 500, userInfo: nil)
    static let Forbidden = NSError(domain: "thuyen.demomvvm", code: 403, userInfo: nil)
    static let NotFound = NSError(domain: "thuyen.demomvvm", code: 404, userInfo: nil)
}

class FetchDataTask {
    
    // MARK: - Use SignalProducer
    func fetchDataFromLocal() -> SignalProducer<[Event], NSError> {
        return SignalProducer { observer, disposable in
            delay(0) {
                let events = FakeModel().generateEvent(capacity: 50)
                observer.sendNext(events)
                observer.sendCompleted()
            }
        }
    }
    
    func fetchDataFromServer() -> SignalProducer<[Event], NSError> {
        return SignalProducer { observer, disposable in
            delay(2) {
                let events = FakeModel().generateEvent(capacity: 20)
                observer.sendNext(events)
                observer.sendCompleted()
            }
        }
    }
}

enum DataItem {
    case EventItem(Event)
    case FeedbackItem
}

// MAK: - EventsViewModel
class EventsViewModel {
    
    var shouldShowFeedbackCell = true
    private var events: [Event] = []
    private let fetchDataTask: FetchDataTask!
    //private(set) var isLoading = MutableProperty(false)
    private(set) var isLoadingMore = MutableProperty(false)
    
    init(fetchDataTask: FetchDataTask) {
        self.fetchDataTask = fetchDataTask
    }
    
    func numberOfDataItems() -> Int {
        if shouldShowFeedbackCell && events.count >= Constants.FeedbackIndex {
            return events.count + 1
        }
        return events.count
    }
    
    func dataItemAtIndex(index: Int) -> DataItem {
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
}

// MARK: - Use completion
// Deprecated
extension EventsViewModel {
    
    func fetchDataFromLocal() -> SignalProducer<[Event], NSError> {
        return fetchDataTask.fetchDataFromLocal()
            .on(started: {
                //self.isLoading.value = true
            })
            .on(next: { events in
                self.events = events
            })
            .on(completed: {
                //self.isLoading.value = false
            })
    }
    
    func fetchDataFromServer() -> SignalProducer<[Event], NSError> {
        return fetchDataTask.fetchDataFromServer()
            .on(started: {
                //self.isLoading.value = true
            })
            .on(next: { events in
                self.events = events
            })
            .on(completed: {
                //self.isLoading.value = false
            })
    }
    
    func fetchMoreData() -> SignalProducer<[Event], NSError> {
        return fetchDataTask.fetchDataFromServer()
            .on(started: {
                self.isLoadingMore.value = true
            })
            .on(next: { events in
                self.events += events
            })
            .on(completed: {
                self.isLoadingMore.value = false
            })
    }
}
