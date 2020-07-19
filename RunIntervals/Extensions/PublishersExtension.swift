//
//  PublishersExtension.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/27.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Combine
import UIKit

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
