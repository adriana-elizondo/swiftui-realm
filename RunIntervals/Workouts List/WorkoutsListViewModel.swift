//
//  WorkoutsListViewModel.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Combine
import Foundation

class WorkoutsListViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    private let db: WorkoutsDBProtocol
    init(db: WorkoutsDBProtocol) {
        self.db = db
        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            self.loading(),
                            Self.userInput(input: input.eraseToAnyPublisher())])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    deinit {
        bag.removeAll()
    }
    //swiftlint:disable empty_enum_arguments
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading:
            switch event {
            case .onWorkoutsLoaded(let workoutList):
                return .loaded(workouts: workoutList)
            case .onWorkoutsFailedToLoad(let error):
                return .failed(error: error)
            default:
                return state
            }
        case .loaded(_):
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .failed(_):
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        }
    }
    func send(event: Event) {
        input.send(event)
    }
}
extension WorkoutsListViewModel {
    //Feedbacks
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
    func loading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
            return type(of: self.db).loadAllRuns()
                .map { Event.onWorkoutsLoaded(workouts: Array($0)) }
                .catch {Just(Event.onWorkoutsFailedToLoad(error: $0)) }
                .eraseToAnyPublisher()
        }
    }
}
extension WorkoutsListViewModel {
    enum State {
        case idle
        case loading
        case loaded(workouts: [Workout])
        case failed(error: Error)
    }
    enum Event {
        case onAppear
        case onWorkoutsLoaded(workouts: [Workout])
        case onWorkoutsFailedToLoad(error: Error)
    }
}
