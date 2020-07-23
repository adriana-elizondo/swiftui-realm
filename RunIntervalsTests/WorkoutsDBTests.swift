//
//  RealmTests.swift
//  RunIntervalsTests
//
//  Created by Adriana Elizondo on 2020/7/21.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import XCTest
import Combine
import RealmSwift
@testable import RunIntervals

class RealmTests: XCTestCase {
    var realm = RealmStore.shared
    override func setUpWithError() throws {
        try? realm.createOrUpdate(object: mockWorkout1)
        try? realm.createOrUpdate(object: mockWorkout2)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testPersistWorkout() {
        XCTAssertNoThrow(try realm.createOrUpdate(object: mockWorkout1))
    }
    func testPersistedWorkout() {
        let expectation = XCTestExpectation(description: "Retrieve stored value successfully")
        let results = WorkoutsDB.loadAllRuns().sink { completion in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure: XCTFail("Completed with error")
            }
        } receiveValue: { results in
            XCTAssertEqual(results.first, mockWorkout1)
            XCTAssertEqual(results.count, 2)
            expectation.fulfill()
        }
        XCTAssertNotNil(results)
        wait(for: [expectation], timeout: 3.0)
    }
    func testLoadAllWorkouts() {
        let expectation = XCTestExpectation(description: "Retrieve 2 mock workouts successfully")
        let results = WorkoutsDB.loadAllRuns().sink { workouts in
            XCTAssertNotNil(workouts)
            XCTAssertEqual(workouts.count, 2)
            expectation.fulfill()
        }
        XCTAssertNotNil(results)
        wait(for: [expectation], timeout: 3.0)
    }
    func testModifyWorkout() {
        let expectation = XCTestExpectation(description: "Retrieve 2 mock workouts successfully")
        let workoutToUpdate: Workout = mockWorkout1
        try? WorkoutsDB.addNew(workout: workoutToUpdate) {
            workoutToUpdate.name = "This is a different name"
        }
        let updatedWorkout = WorkoutsDB.loadSingleWorkout(with: mockWorkout1.id).sink { (completion) in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure: XCTFail("Completed with error")
            }
        } receiveValue: { fetchedWorkout in
            XCTAssertEqual(fetchedWorkout.name, "This is a different name")
            expectation.fulfill()
        }
        XCTAssertNotNil(updatedWorkout)
    }
    func testAddNewIntervalToWorkout() {
        let expectation = XCTestExpectation(description: "Add interval to workout successfully")
        let workoutToAddIntervalTo = mockWorkout2
        try? WorkoutsDB.addNew(interval: mockInterval1, to: workoutToAddIntervalTo)
        let updatedWorkout = WorkoutsDB.loadSingleWorkout(with: mockWorkout2.id).sink { (completion) in
            switch completion {
            case .finished: expectation.fulfill()
            case .failure: XCTFail("Completed with error")
            }
        } receiveValue: { fetchedWorkout in
            XCTAssertNotNil(fetchedWorkout.intervals)
            XCTAssertEqual(fetchedWorkout.intervals.first?.id, mockInterval1.id)
            expectation.fulfill()
        }
        XCTAssertNotNil(updatedWorkout)
    }
}
