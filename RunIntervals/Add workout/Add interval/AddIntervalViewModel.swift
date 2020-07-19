//
//  AddIntervalViewModel.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/26.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Combine
import Foundation

class AddIntervalViewModel: ObservableObject {
    @Published private(set) var state = State.incompleteForm
    @Published var intervalDescription = ""
    @Published var duration = 0
    private let input = PassthroughSubject<Event, Never>()
    private var bag = Set<AnyCancellable>()
    private var workout: Workout
    init(_ workout: Workout) {
        self.workout = workout
        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [self.submit(), self.processFormInput(), self.userInput()])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    deinit {
        bag.removeAll()
    }
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .incompleteForm:
            switch event {
            case .onValidatedData(let valid):
                return valid ? .completeForm : state
            default:
                return state
            }
        case .completeForm:
            switch event {
            case .onValidatedData(let valid):
                return !valid ? .incompleteForm : state
            case .onTapSave:
                return .startedSave
            default:
                return state
            }
        case .addedIntervalToWorkout:
            return state
        case .startedSave:
            switch event {
            case .onFinishedSaving(let interval):
                return .addedIntervalToWorkout(interval: interval)
            default:
                return state
            }
        }
    }
    enum State {
        case incompleteForm
        case completeForm
        case startedSave
        case addedIntervalToWorkout(interval: Interval)
    }
    enum Event {
        case onValidatedData(valid: Bool)
        case onTapSave
        case onFinishedSaving(interval: Interval)
    }
    func send(event: Event) {
        input.send(event)
    }
}
extension AddIntervalViewModel {
    //Feedbacks
    var isDescriptionValid: AnyPublisher<Bool, Never> {
        $intervalDescription
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }
    var isDurationValid: AnyPublisher<Bool, Never> {
        $duration
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { Int($0) > 0 }
            .eraseToAnyPublisher()
    }
    var validateForm: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isDescriptionValid, isDurationValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }
    var saveInterval: Interval {
        let newInterval = Interval()
        newInterval.intervalDescription = intervalDescription
        newInterval.durationInSeconds = duration
        workout.intervals.append(newInterval)
        return newInterval
    }
    func userInput() -> Feedback<State, Event> {
        Feedback(run: { _ in
            return self.input.map { $0 }.eraseToAnyPublisher()
        })
    }
    func processFormInput() -> Feedback<State, Event> {
        Feedback { _ in
            return self.validateForm.map { Event.onValidatedData(valid: $0) }.eraseToAnyPublisher()
        }
    }
    func submit() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .startedSave = state else { return Empty().eraseToAnyPublisher() }
            let interval = self.saveInterval
            return Just(Event.onFinishedSaving(interval: interval)).eraseToAnyPublisher()
        }
    }
}
