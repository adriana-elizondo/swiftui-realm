//
//  Workout.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Foundation
import RealmSwift

@objcMembers
class Workout: Object, ObjectKeyIdentifable {
    //swiftlint:disable identifier_name
    dynamic var id = UUID().uuidString
    dynamic var date = Date()
    dynamic var name = ""
    dynamic var workoutDescription = ""
    dynamic var numberOfSets = 0
    let intervals = List<Interval>()
    override static func primaryKey() -> String? {
        return "id"
    }
}

@objcMembers
class Interval: Object, Identifiable {
    dynamic var id = UUID().uuidString
    dynamic var intervalDescription = ""
    dynamic var durationInSeconds: Int = 0
}

extension Workout {
    var durationInSeconds: Int {
        let total = intervals.reduce(0) { $0 + $1.durationInSeconds }
        return total
    }
}

let mockWorkout1 = Workout(value: ["id": UUID().uuidString,
                                   "date": Date(),
                                   "name": "Sample 1",
                                   "workoutDescription": "Sample 1 description",
                                   "numberOfSets": 10,
                                   "intervals": [["id": UUID().uuidString,
                                   "intervalDescription": "This is a description",
                                    "durationInSeconds": 220]]])
let mockWorkout2 = Workout(value: ["id": UUID().uuidString,
                                   "date": Date(),
                                   "name": "Sample 2",
                                   "workoutDescription": "Sample 2 description",
                                   "numberOfSets": 12])
