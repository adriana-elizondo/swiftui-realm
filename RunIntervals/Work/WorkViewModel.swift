//
//  WorkViewModel.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/27.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Combine
import Foundation

class WorkViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    private(set) var workout: Workout
    init(with workout: Workout) {
        self.workout = workout
    }
}

extension WorkViewModel {
    enum State {
        case idle
        case working
        case transitioning(nextInterval: Interval)
        case paused
        case stopped
    }
    enum Event {
        case onInputData
        case onValidatedData(valid: Bool)
        case onTapSave
        case onFinishedSaving(error: Error?)
    }
}
