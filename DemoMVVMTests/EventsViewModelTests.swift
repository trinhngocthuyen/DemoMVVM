//
//  EventsViewModelTests.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/20/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import XCTest
import Nimble
import ReactiveCocoa
@testable import DemoMVVM

class EventsViewModelTests: XCTestCase {
    
    // Mock FetchDataTask
    class MockFetchDataTask: FetchDataTask {
        var numberOfItems: Int? = 0
        var delayForResponse: Double = 2
        
        func setupParams(numberOfItems: Int?, delayForResponse: Double = 0) {
            self.numberOfItems = numberOfItems
            self.delayForResponse = delayForResponse
        }
        
        override func fetchDataFromServer() -> SignalProducer<[DemoMVVM.Event], NSError> {
            return SignalProducer { observer, disposable in
                delay(self.delayForResponse) {
                    if let numberOfItems = self.numberOfItems {
                        let events = FakeModel().generateEvent(capacity: numberOfItems)
                        observer.sendNext(events)
                        observer.sendCompleted()
                    } else {
                        observer.sendFailed(APIError.RequestTimeout)
                    }
                }
            }
        }
    }
    
    var fetchDataTask: MockFetchDataTask!
    var eventsViewModel: EventsViewModel!
    
    override func setUp() {
        super.setUp()
        
        fetchDataTask = MockFetchDataTask()
        eventsViewModel = EventsViewModel(fetchDataTask: fetchDataTask)
    }
    
    /// Test: Pre-setup
    func testPreSetup() {
        expect(self.eventsViewModel.isLoadingMore.value).to(beFalse())
        expect(self.eventsViewModel.numberOfDataItems()).to(equal(0))
    }
    
    /// Test: Number of items when shouldShowFeedbackCell = true
    func testEventsViewModel_NumberOfItems_When_HaveFeedbackCell() {
        // Given
        let delayForResponse: Double = 1.0
        fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
        eventsViewModel.shouldShowFeedbackCell = true
        
        // When
        eventsViewModel.fetchDataFromServer().start()
        
        // Expect
        expect(self.eventsViewModel.numberOfDataItems()).toEventually(equal(50 + 1), timeout: delayForResponse + 0.1)
        
    }
    
    /// Test: Number of items when shouldShowFeedbackCell == false
    func testEventsViewModel_NumberOfItems_When_NotHaveFeedbackCell() {
        // Given
        let delayForResponse: Double = 1.0
        fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
        eventsViewModel.shouldShowFeedbackCell = false
        
        // When
        eventsViewModel.fetchDataFromServer().start()
        
        // Expect
        expect(self.eventsViewModel.numberOfDataItems()).toEventually(equal(50), timeout: delayForResponse + 0.1)
    }
    
    /// Test: Number of items should increase after loading more
    func testEventsViewModel_NumberOfItems_ShouldIncrease_AfterLoadMore() {
        // Given
        let delayForResponse: Double = 1.0
        fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
        eventsViewModel.shouldShowFeedbackCell = false
        
        // When
        // Fetch data: it should take time as delayForResponse
        eventsViewModel.fetchDataFromServer().start()
        
        // Fetch more data
        let startTimeOfFetchMore = delayForResponse + 0.1
        let endTimeOfFetchMore = startTimeOfFetchMore + delayForResponse
        delay(startTimeOfFetchMore) {
            self.fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
            self.eventsViewModel.fetchMoreData().start()
        }
        
        // Expect
        // Right before finishing fetching more
        // ------------- ||| finish -------------
        expect(self.eventsViewModel.numberOfDataItems())
            .toEventually(equal(50), timeout: endTimeOfFetchMore - 0.1)
        
        // Right after finishing fetching more
        // ------------- finish ||| -------------
        expect(self.eventsViewModel.numberOfDataItems())
            .toEventually(equal(100), timeout: endTimeOfFetchMore + 0.1)
    }
    
    /// Test: Number of items should increase after loading more
    func testEventsViewModel_FetchMore_Should_Lock_AnotherFetchMore() {
        // Given
        let delayForResponse: Double = 1.0
        fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
        eventsViewModel.shouldShowFeedbackCell = false
        
        // When
        // Fetch data: it should take time as delayForResponse
        eventsViewModel.fetchDataFromServer().start()
        
        // Fetch more data
        let startTimeOfFetchMore = delayForResponse + 0.1
        let endTimeOfFetchMore = startTimeOfFetchMore + 1.0
        delay(startTimeOfFetchMore) {
            self.fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
            self.eventsViewModel.fetchMoreData().start()
        }
        
        // Expect
        // Right before STARTING fetching more
        // ------------- ||| start -------------
        expect(self.eventsViewModel.isLoadingMore.value)
            .toEventually(beFalse(), timeout: startTimeOfFetchMore - 0.1)
        
        // Right after STARTING fetching more
        // ------------- start ||| -------------
        expect(self.eventsViewModel.isLoadingMore.value)
            .toEventually(beTrue(), timeout: startTimeOfFetchMore + 0.1)
        
        // Right before FINISHING fetching more
        // ------------- ||| finish -------------
        expect(self.eventsViewModel.isLoadingMore.value)
            .toEventually(beTrue(), timeout: endTimeOfFetchMore - 0.1)
        
        // Right after FINISHING fetching more
        // ------------- finish ||| -------------
        expect(self.eventsViewModel.isLoadingMore.value)
            .toEventually(beFalse(), timeout: endTimeOfFetchMore + 0.1)
    }
    
    /// Test: Item at index 3 should be feedback cell
    func testItemAtFeedbackIndex_ShouldBe_FeedbackCell() {
        // Given
        let delayForResponse: Double = 1.0
        fetchDataTask.setupParams(50, delayForResponse: delayForResponse)
        eventsViewModel.shouldShowFeedbackCell = true
        
        // When
        eventsViewModel.fetchDataFromServer().start()
        
        // Expect
        let endTimeOfFetchData = delayForResponse
        let checkFeedbackItem: DataItem -> Bool = { item in
            switch item {
            case .FeedbackItem: return true
            case _: return false
            }
        }
        expect(checkFeedbackItem(self.eventsViewModel.dataItemAtIndex(Constants.FeedbackIndex)))
            .toEventually(beTrue(), timeout: endTimeOfFetchData + 0.1)
    }
}
