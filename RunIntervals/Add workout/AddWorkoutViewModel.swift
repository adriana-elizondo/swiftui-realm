//
//  AddWorkoutViewModel.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Combine
import Foundation

class AddWorkoutViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    @Published var name = ""
    @Published var description = ""
    @Published var numberOfSets = ""
    @Published var workout = Workout()
    private let input = PassthroughSubject<Event, Never>()
    private var bag = Set<AnyCancellable>()
    init() {
        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [self.userInput(), self.inputData(), self.submit()])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    deinit {
        bag.removeAll()
    }
    //swiftlint:disable cyclomatic_complexity
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onValidatedData(let valid):
                return valid ? .completeForm : .incompleteForm
            default:
                return state
            }
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
        case .savedSuccessFully:
            return state
        case .errorSaving:
            return state
        case .startedSave:
            switch event {
            case .onFinishedSaving(let error):
                return error == nil ? .savedSuccessFully : .errorSaving(error: error!)
            default:
                return state
            }
        }
    }
    enum State {
        case idle
        case incompleteForm
        case completeForm
        case startedSave
        case savedSuccessFully
        case errorSaving(error: Error)
    }
    enum Event {
        case onInputData
        case onValidatedData(valid: Bool)
        case onTapSave
        case onFinishedSaving(error: Error?)
    }
    func send(event: Event) {
        input.send(event)
    }
}
extension AddWorkoutViewModel {
    //Feedbacks
    var isNameValid: AnyPublisher<Bool, Never> {
        $name
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0.count >= 3 }
        .eraseToAnyPublisher()
    }
    var isDescriptionValid: AnyPublisher<Bool, Never> {
        $description
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { !$0.isEmpty }
        .eraseToAnyPublisher()
    }
    var validateForm: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isNameValid, isDescriptionValid)
            .map { validName, validDescription in
                return validName && validDescription
            }
        .eraseToAnyPublisher()
    }
    var saveWorkout: Error? {
        let newWorkout = self.workout
        return WorkoutsDB.addNew(workout: newWorkout, updateClosure: {
            newWorkout.name = self.name
            newWorkout.workoutDescription = self.description
        })
    }
    func userInput() -> Feedback<State, Event> {
        Feedback(run: { _ in
            return self.input.map { $0 }.eraseToAnyPublisher()
        })
    }
    func inputData() -> Feedback<State, Event> {
        Feedback { _ in
            return self.validateForm.map { Event.onValidatedData(valid: $0) }.eraseToAnyPublisher()
        }
    }
    func submit() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .startedSave = state else { return Empty().eraseToAnyPublisher() }
            let error = self.saveWorkout
            if error == nil {
                return Just(Event.onFinishedSaving(error: nil)).eraseToAnyPublisher()
            } else {
                return Just(Event.onFinishedSaving(error: error)).eraseToAnyPublisher()
            }
        }
    }
}
