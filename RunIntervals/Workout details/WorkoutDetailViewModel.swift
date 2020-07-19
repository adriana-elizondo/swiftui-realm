//
//  WorkoutDetailViewModel.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/27.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Combine
import Foundation

class WorkoutDetailViewModel: ObservableObject {
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    var timer = Timer.publish(every: 1, on: .main, in: .default)
    private var cancellable: Cancellable?
    @Published private(set) var workout: Workout
    @Published private(set) var interval: Interval?
    @Published private(set) var state = State.idle
    init(with workout: Workout) {
        self.workout = workout
        Publishers.system(initial: state,
                          reduce: self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [self.userInput(input: input.eraseToAnyPublisher())])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    deinit {
        bag.removeAll()
    }
    func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .startedOrResumedWorkout:
                return .working
            default:
                return state
            }
        case .working:
            switch event {
            case .workoutAdvanced:
                return .working
            case .pausedWorkout:
                return .pausedWorkout
            default:
                return state
            }
        case .pausedWorkout:
            switch event {
            case .startedOrResumedWorkout:
                return .working
            case .stoppedWorkout:
                return .stoppedWorkout
            default:
                return state
            }
        case .stoppedWorkout:
            return state
        }
    }
    func send(event: Event) {
        input.send(event)
    }
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .default)
        cancellable = timer.connect()
    }
    private func stopTimer() {
        cancellable?.cancel()
    }
}
extension WorkoutDetailViewModel {
    //Feedbacks
    func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            switch state {
            case .idle:
                return input.map {
                    if case .startedOrResumedWorkout = $0 {
                        self.startTimer()
                        return Event.startedOrResumedWorkout
                    }
                    return Event.onAppear
                }.eraseToAnyPublisher()
            case .working:
                return input.map {
                    switch $0 {
                    case .pausedWorkout:
                        self.stopTimer()
                        return Event.pausedWorkout
                    case .stoppedWorkout:
                        self.stopTimer()
                        return Event.stoppedWorkout
                    default:
                        return Event.workoutAdvanced
                    }
                }
                .eraseToAnyPublisher()
            case .pausedWorkout:
                return input.map {
                    switch $0 {
                    case .startedOrResumedWorkout:
                        self.startTimer()
                        return Event.startedOrResumedWorkout
                    default:
                        return Event.pausedWorkout
                    }
                }
                .eraseToAnyPublisher()
            default:
                return Just(Event.workoutAdvanced).eraseToAnyPublisher()
            }
        }
    }
}
extension WorkoutDetailViewModel {
    enum State {
        case idle
        case working
        case pausedWorkout
        case stoppedWorkout
    }
    enum Event {
        case onAppear
        case startedOrResumedWorkout
        case workoutAdvanced
        case pausedWorkout
        case stoppedWorkout
    }
}
