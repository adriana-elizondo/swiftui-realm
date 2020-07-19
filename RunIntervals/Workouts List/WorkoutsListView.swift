//
//  WorkoutsListView.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import SwiftUI

struct WorkoutsListView: View {
    @ObservedObject private(set) var viewModel: WorkoutsListViewModel
    var body: some View {
        NavigationView {
            content.navigationBarTitle("Workouts")
                .navigationBarItems(trailing:
                                        NavigationLink(destination: AddWorkoutView(viewModel: AddWorkoutViewModel())) {
                                            Image(systemName: "plus").colorMultiply(.black)})
                .onAppear { self.viewModel.send(event: .onAppear) }
        }
    }
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return Spinner(isAnimating: true, style: .medium).eraseToAnyView()
        case .failed(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let workouts):
            return workouts.count > 0
                ? list(of: workouts).eraseToAnyView()
                : Text("Tap + to add a new workout").eraseToAnyView()
        }
    }
    private func list(of workouts: [Workout]) -> some View {
        return List(workouts) { workout in
            self.listItem(with: workout)
        }
    }
    private func listItem(with workout: Workout) -> some View {
        VStack {
           let workoutDetailView = WorkoutDetailView(viewModel: WorkoutDetailViewModel(with: workout))
            NavigationLink(destination: workoutDetailView) {
                Text(workout.name)
            }
        }
    }
}

struct WorkoutsListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(viewModel: WorkoutsListViewModel(db: MockWorkoutsDB()))
    }
}
