//
//  CustomRangeCircularSlider.swift
//  HGCircularSlider_Example
//
//  Created by An Nguyen Hoang on 10/06/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

open class CustomRangeCircularSlider: RangeCircularSlider {
    
    open var minimumRangeValue: CGFloat = 0 {
        didSet {
            assert(minimumRangeValue <= maximumValue - minimumValue, "The minimum range value is greater than distance between max and min value")
        }
    }
    
    open var maximumRangeValue: CGFloat = 0 {
        didSet {
            assert(maximumRangeValue <= maximumValue - minimumValue, "The maximum range value is greater than distance between max and min value")
        }
    }
    
    fileprivate var selectedThumb: SelectedThumb = .none
    fileprivate var nearMax: Bool = false
    fileprivate var intervalStart: CGFloat = 0
    fileprivate var intervalEnd: CGFloat = 0
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        sendActions(for: .editingDidBegin)
        let touchPosition = touch.location(in: self)
        selectedThumb = thumb(for: touchPosition)
        guard selectedThumb == .none else { return true }
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        let oldValue: CGFloat = startPointValue
        let value = newValue(from: oldValue, touch: touchPosition, start: startPoint)
        if startPointValue < endPointValue {
            guard value > startPointValue && value < endPointValue else { return false }
        } else {
            guard value > startPointValue || value < endPointValue else { return false }
        }
        intervalStart = startPointValue < value ? value - startPointValue : value + maximumValue - startPointValue
        intervalEnd = value < endPointValue ? endPointValue - value : endPointValue + maximumValue - value
        return true
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPosition = touch.location(in: self)
        let startPoint = CGPoint(x: bounds.center.x, y: 0)
        var isContinue = false
        if selectedThumb != .none {
            let oldValue: CGFloat = selectedThumb.isStart ? startPointValue : endPointValue
            let value = newValue(from: oldValue, touch: touchPosition, start: startPoint)
            if selectedThumb.isStart {
                let distanceDelta: CGFloat = value < endPointValue ? 0 : maximumValue
                let actualDistance = endPointValue + distanceDelta - value
                if actualDistance > maximumRangeValue || actualDistance < minimumRangeValue {
                    if nearMax {
                        startPointValue = endPointValue >= maximumRangeValue ? endPointValue - maximumRangeValue : maximumValue + (endPointValue - maximumRangeValue)
                    } else {
                        startPointValue = endPointValue >= minimumRangeValue ? endPointValue - minimumRangeValue : maximumValue - (minimumRangeValue - endPointValue)
                    }
                } else {
                    nearMax = actualDistance > (maximumValue - minimumValue) / 2
                    startPointValue = value
                    isContinue = true
                }
            } else {
                let distanceDelta: CGFloat = startPointValue < value ? 0 : maximumValue
                let actualDistance = value + distanceDelta - startPointValue
                if actualDistance > maximumRangeValue || actualDistance < minimumRangeValue {
                    if nearMax {
                        endPointValue = startPointValue + maximumRangeValue - maximumValue
                    } else {
                        endPointValue = startPointValue < (maximumValue - minimumRangeValue) ? startPointValue + minimumRangeValue : maximumValue - startPointValue + minimumRangeValue
                    }
                } else {
                    nearMax = actualDistance > (maximumValue - minimumValue) / 2
                    endPointValue = value
                    isContinue = true
                }
            }
        } else {
            let oldValue: CGFloat = startPointValue
            let value = newValue(from: oldValue, touch: touchPosition, start: startPoint)
            if value - intervalStart < minimumValue {
                startPointValue = value - intervalStart + maximumValue
            } else {
                startPointValue = value - intervalStart
            }
            if value + intervalEnd > maximumValue {
                endPointValue = value + intervalEnd - maximumValue
            } else {
                endPointValue = value + intervalEnd
            }
            isContinue = true
        }
        sendActions(for: .valueChanged)
        return isContinue
    }
}
