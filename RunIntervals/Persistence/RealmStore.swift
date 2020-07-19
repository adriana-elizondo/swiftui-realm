//
//  RealmStore.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Combine
import Foundation
import RealmSwift

protocol PersistenceStore {
    func fetch<O: Object>(with predicate: String) -> AnyPublisher<Results<O>, Error>
    func update<O>(object: O, updateClosure: (() -> Void)?) throws where O: Object
}

class RealmStore: PersistenceStore {
    static let shared = RealmStore()
    private var realm: Realm
    private init() {
        var config = Realm.Configuration()
        //Default realm compact function
        config.shouldCompactOnLaunch = { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneHundredMB = 100 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        }
        do {
            self.realm = try Realm()
        } catch let error as NSError {
            fatalError("Realm instance couldn't be created \(error)")
        }
    }
    func fetch<O: Object>() -> AnyPublisher<Results<O>, Error> {
        return realm.objects(O.self).publisher.eraseToAnyPublisher()
    }
    func fetch<O: Object>(with predicate: String) -> AnyPublisher<Results<O>, Error> {
        return realm.objects(O.self).filter(predicate).publisher.eraseToAnyPublisher()
    }
    func update<O>(object: O, updateClosure: (() -> Void)? = nil) throws where O: Object {
        do {
            try realm.write {
                updateClosure?()
                realm.add(object, update: .modified)
            }
        } catch let error {
            throw error
        }
    }
}
