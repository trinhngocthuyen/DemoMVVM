//
//  RAC_Extensions.swift
//  DemoMVVM
//
//  Created by Thuyen Trinh on 3/21/16.
//  Copyright © 2016 Thuyen Trinh. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import enum Result.NoError

extension Observer {
    public func sendNextAndCompleted(value: Value) {
        self.sendNext(value)
        self.sendCompleted()
    }
}

extension SignalType {
    public func ignoreError(replacement replacement: ReactiveCocoa.Event<Value, NoError> = .Completed) -> Signal<Value, NoError> {
        precondition(replacement.isTerminating)
        
        return Signal<Value, NoError> { observer in
            return self.observe { event in
                switch event {
                case let .Next(value):
                    observer.sendNext(value)
                case .Failed:
                    observer.action(replacement)
                case .Completed:
                    observer.sendCompleted()
                case .Interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }
}

extension SignalProducerType {
    public func ignoreError(replacement replacement: ReactiveCocoa.Event<Value, NoError> = .Completed) -> SignalProducer<Value, NoError> {
        precondition(replacement.isTerminating)
        return lift { $0.ignoreError(replacement: replacement) }
    }
    
    public func merge(other: SignalProducer<Value, Error>) -> SignalProducer<Value, Error> {
        return SignalProducer<SignalProducer<Value, Error>, Error>(values: [self.producer, other]).flatten(.Merge)
    }
    
    public func merge(others: [SignalProducer<Value, Error>]) -> SignalProducer<Value, Error> {
        return SignalProducer<SignalProducer<Value, Error>, Error>(values: [self.producer] + others).flatten(.Merge)
    }
    
    public func thenIgnoringError<U>(next: SignalProducer<U, Error>) -> SignalProducer<U, Error> {
        let relay = SignalProducer<U, Error> { observer, observerDisposable in
            self.startWithSignal { signal, signalDisposable in
                observerDisposable.addDisposable(signalDisposable)
                
                signal.observe { event in
                    switch event {
                    case .Failed(_), .Completed:
                        observer.sendCompleted()
                    case .Interrupted:
                        observer.sendInterrupted()
                    case .Next:
                        break
                    }
                }
            }
        }
        
        return relay.concat(next)
    }
    
    public func concatIgnoringError(next: SignalProducer<Value, Error>) -> SignalProducer<Value, Error> {
        return self.producer.flatMapError { _ in next }.concat(next)
    }
    
    public func mapToVoid() -> SignalProducer<Void, Error> {
        return self.map { _ in () }
    }
    
    public func observeOnMain() -> SignalProducer<Self.Value, Self.Error> {
        return self.observeOn(QueueScheduler.mainQueueScheduler)
    }
    
    public func throttleOnMain(interval: NSTimeInterval) -> SignalProducer<Self.Value, Self.Error> {
        return self.throttle(interval, onScheduler: QueueScheduler.mainQueueScheduler)
    }
    
    public func addBinding(mutableProperty: MutableProperty<Value>) {
        mutableProperty <~ self.ignoreError()
    }
    
    public func addBinding<U>(mutableProperty: MutableProperty<U>, transform: Value -> U) -> Self {
        mutableProperty <~ self.map(transform).ignoreError()
        return self
    }
    
    public func logWhenStarted(logText: String) -> SignalProducer<Value, Error> {
        return self.on(started: {
            NSLog(logText)
        })
    }
    
    public func logWhenCompleted(logText: String) -> SignalProducer<Value, Error> {
        return self.on(completed: {
            NSLog(logText)
        })
    }
    
    public func logWhenNext(logText: String) -> SignalProducer<Value, Error> {
        return self.on(next: { _ in
            NSLog(logText)
        })
    }
    
    public func logWhenNext(log: Value -> String) -> SignalProducer<Value, Error> {
        return self.on(next: { value in
            NSLog(log(value))
        })
    }
    
    public func logWhenFailed(logText: String) -> SignalProducer<Value, Error> {
        return self.on(failed: { error in
            NSLog(logText + ". Error: \(error)")
        })
    }
    
    // NOTE: tnthuyen: In RAC 4.2.2, `startWithNex` is marked deprecated
    // https://github.com/ReactiveCocoa/ReactiveCocoa/releases/tag/v4.2.2
    // Replacing them all with a different syntax is kind of cumbersome
    // --> Replace them by this function
    public func mf_startWithNext(nextBlock: (Value -> Void)?) -> Disposable {
        return self.on(next: nextBlock).start()
    }
}

extension SignalProducerType where Value == Bool {
    public func ignoreFalse() -> SignalProducer<Self.Value, Self.Error> {
        return self.filter({ $0 })
    }
}

// MARK: - Optionals
// Let's use the protocol OptionalType of ReactiveCocoa
// It's so common that every lib writes the same protocol with the same implementation (and marked as public)
// No need to implement it again
extension OptionalType where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self.optional == nil || self.optional == ""
    }
}

extension OptionalType where Wrapped: CollectionType {
    var isNilOrEmpty: Bool {
        if self.optional == nil { return true }
        return self.optional!.isEmpty
    }
}

struct AssociationKey {
    static let Text = "Text"
    static let Enable = "Enable"
    static let Hidden = "Hidden"
    static let Alpha = "Alpha"
    static let ContentOffset = "ContentOffset"
    static let Placeholder = "Placeholder"
    static let On = "On"
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>,
                         setter: T -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .mf_startWithNext({ newValue in
                setter(newValue)
            })
        return property
    }
}

func lazyAssociatedProperty<T: AnyObject>(host: AnyObject,
                            key: UnsafePointer<Void>, factory: ()->T) -> T {
    var associatedProperty = objc_getAssociatedObject(host, key) as? T
    
    if associatedProperty == nil {
        associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
    return associatedProperty!
}

// MARK: - UIView
extension UIView {
    var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: AssociationKey.Hidden
            , setter: { self.hidden = $0 }
            , getter: { self.hidden })
    }
    
    var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: AssociationKey.Alpha
            , setter: { self.alpha = $0 }
            , getter: { self.alpha })
    }
}

// MARK: - UIButton
extension UIButton {
    var rac_enable: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: AssociationKey.Enable
            , setter: { self.enabled = $0 }
            , getter: { self.enabled })
    }
}

// MARK: - UILabel
extension UILabel {
    var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: AssociationKey.Text
            , setter: { self.text = $0 }
            , getter: { self.text ?? "" })
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}

// MARK: - UITextField
extension UITextField {
    var rac_textProducer: SignalProducer<String, NSError> {
        let producer =  rac_textSignal().toSignalProducer()
            .map { $0 as? String }
            .ignoreNil()
        return producer
    }
    
    var rac_isFocusing: SignalProducer<Bool, NSError> {
        let initialProducer = SignalProducer<Bool, NSError>(value: isFirstResponder())
        let beginEditingProducer = rac_signalForControlEvents(.EditingDidBegin).toSignalProducer().map { _ in true }
        let endEditingProducer = rac_signalForControlEvents(.EditingDidEnd).toSignalProducer().map { _ in false }
        return initialProducer.merge([beginEditingProducer, endEditingProducer])
    }
    
    var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: AssociationKey.Text
            , setter: { self.text = $0 }
            , getter: { self.text ?? "" })
    }
    
    var rac_placeholder: MutableProperty<String> {
        return lazyMutableProperty(self, key: AssociationKey.Placeholder
            , setter: { self.placeholder = $0 }
            , getter: { self.placeholder ?? "" })
    }
}

// MARK: - ScrollView
extension UIScrollView {
    var rac_contentOffset: MutableProperty<CGPoint> {
        return lazyMutableProperty(self, key: AssociationKey.ContentOffset
            , setter: { self.contentOffset = $0 }
            , getter: { self.contentOffset })
    }
}

// MARK: - UIDatePicker
extension UIDatePicker {
    var rac_selectedDate: SignalProducer<NSDate, NoError> {
        return rac_signalForControlEvents(.ValueChanged)
            .toSignalProducer()
            .map { x -> NSDate? in
                return (x as? UIDatePicker)?.date
            }
            .ignoreNil()
            .ignoreError()
    }
}

// MARK: - UISwitch
extension UISwitch {
    var rac_on: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: AssociationKey.On
            , setter: { self.on = $0 }
            , getter: { return self.on })
    }
}
