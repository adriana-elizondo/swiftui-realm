//
//  NotificationExtension.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/27.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
