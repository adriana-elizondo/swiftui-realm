//
//  RealmCollectionProxy.swift
//  RunningIntervals
//
//  Created by Adriana Elizondo on 2020/5/18.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import Combine
import RealmSwift

@propertyWrapper
public class RealmCombineCollection<R: Object> {
    private var results: Results<R>? {
        didSet {
            notificationToken?.invalidate()
            notificationToken = results?.observe({ [weak self] _ in
                guard let self = self else { return }
                self.subject.send(self.wrappedValue)
            })
        }
    }
    public typealias Output = [R]
    private let subject = PassthroughSubject<Results<R>, Never>()
    private var notificationToken: NotificationToken?
    public init() {}
    public func setResults(results: Results<R>) {
        self.results = results
        notificationToken = results.observe({ [weak self] _ in
            guard let welf = self else { return }
            welf.subject.send(welf.wrappedValue)
        })
    }
    public var wrappedValue: Results<R> {
        guard results != nil else {
            fatalError("You didnt provide the result list for \(R.self)") }
        return results!
    }
    public var projectedValue: AnyPublisher<[R], Never> {
        self.subject.map { Array($0) }.eraseToAnyPublisher()
    }
    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never,
        RealmCombineCollection.Output == S.Input {
            projectedValue.receive(subscriber: subscriber)
    }
    deinit {
        notificationToken?.invalidate()
    }
}
