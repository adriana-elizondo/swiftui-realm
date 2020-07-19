//
//  IntExtensions.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/7/19.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Foundation

extension Int {
    func secondsToTime() -> String {
        let (hours, minutes, seconds) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)

       // let hstring = hours < 10 ? "0\(hours)" : "\(hours)"
        let mstring =  minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let sstring =  seconds < 10 ? "0\(seconds)" : "\(seconds)"

        return "\(mstring):\(sstring)"
    }
}
