//
//  WorkoutDetailView.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/27.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import SwiftUI

struct WorkoutDetailConfig {
    var progress = 0
    var time = 0
    var totalDuration = 0
    var timeLeft = 0
    var isWorking = false
    mutating func increaseOneSecond() {
        time += 1
        progress = totalDuration > 0 ? (totalDuration / time) : 0
        timeLeft = abs(totalDuration - time)
    }
    mutating func startedWorkWith(totalDuration: Int) {
        self.totalDuration = totalDuration
        self.timeLeft = totalDuration - time
        self.isWorking = true
    }
    mutating func stoppedWork() {
        self.isWorking = false
    }
}

struct WorkoutDetailView: View {
    @ObservedObject private(set) var viewModel: WorkoutDetailViewModel
    @State var detailConfig = WorkoutDetailConfig()
    var body: some View {
        content
            .onAppear { self.viewModel.send(event: .onAppear) }
    }
    private var editButton: some View {
        Button(action: {}) {
            Image(systemName: "pencil")
        }.padding(.all)
    }
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return contentView(workout: viewModel.workout,
                               interval: viewModel.interval)
        case .working:
            DispatchQueue.main.async {
                detailConfig.startedWorkWith(totalDuration: viewModel.workout.durationInSeconds)
            }
            return contentView(workout: viewModel.workout, interval: viewModel.interval)
        case .pausedWorkout:
            DispatchQueue.main.async {
                detailConfig.stoppedWork()
            }
            return contentView(workout: viewModel.workout, interval: viewModel.interval)
        default:
            return contentView(workout: viewModel.workout, interval: viewModel.interval)
        }
    }
    private func contentView(workout: Workout, interval: Interval?) -> some View {
        return GeometryReader { geometry in
            VStack {
                ZStack(alignment: .top) {
                    Color.pink.opacity(0.8)
                    VStack {
                        Spacer()
                        Text(workout.name)
                            .foregroundColor(.white)
                            .padding()
                        Text(detailConfig.time.secondsToTime())
                            .padding()
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                            .onReceive(viewModel.timer) { _ in
                                detailConfig.increaseOneSecond()
                            }
                        HStack {
                            Text(interval?.intervalDescription ?? "No intervals added")
                                .foregroundColor(.white)
                        }
                        .padding()
                        HStack {
                            VStack {
                                Text(detailConfig.time.secondsToTime())
                                    .foregroundColor(.white)
                                Text("Elapsed")
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack {
                                Text(detailConfig.timeLeft.secondsToTime())
                                    .foregroundColor(.white)
                                Text("Remaining")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .frame(width: geometry.size.width, height: geometry.size.height / 2, alignment: .top)
                ZStack {
                    Color.pink
                    BottomView(config: $detailConfig, viewModel: viewModel)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    struct BottomView: View {
        @Binding var config: WorkoutDetailConfig
        @ObservedObject private(set) var viewModel: WorkoutDetailViewModel
        var body: some View {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Button(action: {
                        if config.isWorking {
                            viewModel.send(event: .pausedWorkout)
                        } else {
                            viewModel.send(event: .startedOrResumedWorkout)
                        }
                    }) {
                        Text(config.isWorking ? "STOP" : "START")
                    }
                    .frame(width: geometry.size.width / 3, height: geometry.size.width / 3, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(Color.clear)
                    .overlay(ZStack {
                        Circle()
                            .stroke(lineWidth: 1.0)
                            .opacity(0.3)
                            .foregroundColor(Color.white)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(config.progress))
                            .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.white)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear)
                    })
                    Spacer()
                    Text("Long press to stop")
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(viewModel: WorkoutDetailViewModel(with: mockWorkout1))
    }
}
