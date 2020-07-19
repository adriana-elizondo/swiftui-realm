//
//  WorkoutsDB.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Combine
import RealmSwift

protocol WorkoutsDBProtocol {
    static func loadAllRuns() -> AnyPublisher<[Workout], Never>
    static func addNew(workout: Workout, updateClosure: (() -> Void)?) -> Error?
    static func addNew(interval: Interval, to workout: Workout) -> Error?
}

struct WorkoutsDB: WorkoutsDBProtocol {
    static func loadAllRuns() -> AnyPublisher<[Workout], Never> {
        let workouts: AnyPublisher<Results<Workout>, Error> = RealmStore.shared.fetch()
        return workouts.map { Array($0.sorted(byKeyPath: "date")) }.replaceError(with: [mockWorkout1]).eraseToAnyPublisher()
    }
    static func addNew(workout: Workout, updateClosure: (() -> Void)? = nil) -> Error? {
        do {
            try RealmStore.shared.update(object: workout, updateClosure: updateClosure)
            return nil
        } catch let error {
            return error
        }
    }
    static func addNew(interval: Interval, to workout: Workout) -> Error? {
        do {
            try RealmStore.shared.update(object: workout, updateClosure: {
                workout.intervals.append(interval)
            })
            return nil
        } catch let error {
            return error
        }
    }
}

struct MockWorkoutsDB: WorkoutsDBProtocol {
    static func loadAllRuns() -> AnyPublisher<[Workout], Never> {
        return Just([mockWorkout1, mockWorkout2]).eraseToAnyPublisher()
    }
    static func addNew(workout: Workout, updateClosure: (() -> Void)?) -> Error? {
        return nil
    }
    static func addNew(interval: Interval, to workout: Workout) -> Error? {
        return nil
    }
}
