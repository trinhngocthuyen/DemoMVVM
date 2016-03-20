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
}

struct AssociationKey {
    static let text = "text"
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>,
    setter: T -> (), getter: () -> T) -> MutableProperty<T> {
        return lazyAssociatedProperty(host, key: key) {
            let property = MutableProperty<T>(getter())
            property.producer
                .startWithNext({ newValue in
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

extension UILabel {
    var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: AssociationKey.text
            , setter: { self.text = $0 }
            , getter: { return self.text ?? "" })
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}

extension UITextField {
    var rac_textProducer: SignalProducer<String, NSError> {
        let producer =  rac_textSignal().toSignalProducer()
            .filter { $0 != nil }
            .map { $0 as! String }
        return producer
    }
    
}