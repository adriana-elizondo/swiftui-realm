//
//  AddWorkoutView.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import Combine
import SwiftUI

struct WorkoutEditorConfig {
    var presentSheet = false
    var keyboardHeight: CGFloat = 0
    var numberOfSets: Int = 0
    var showPicker = false
    mutating func newKeyboardHeight(keyboardHeight: CGFloat) {
        self.keyboardHeight = keyboardHeight
    }
}

struct AddWorkoutView: View {
    @ObservedObject private(set) var viewModel: AddWorkoutViewModel
    @State private var editorConfig = WorkoutEditorConfig()
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading) {
                    workoutName
                    Divider()
                    workoutDescription
                    Divider()
                    HStack {
                        Button(action: {
                            editorConfig.showPicker.toggle()
                        }) {
                            Text("Number of sets")
                        }
                        .padding()
                        Text("\(editorConfig.numberOfSets)")
                    }
                    Divider()
                    list().padding()
                }
            }
            addWorkStack
            Spacer()
        }
        .overlay(SetsPicker(editorConfig: $editorConfig))
        .padding(.bottom, editorConfig.keyboardHeight)
        .padding(.horizontal, 20)
        .navigationBarTitle("New workout")
        .navigationBarItems(trailing: saveButton)
        .sheet(isPresented: $editorConfig.presentSheet) {
            AddIntervalView(viewModel: AddIntervalViewModel(viewModel.workout))
        }
        .onReceive(Publishers.keyboardHeight, perform: { editorConfig.newKeyboardHeight(keyboardHeight: $0) })
    }
    struct SetsPicker: View {
        @Binding var editorConfig: WorkoutEditorConfig
        var body: some View {
            VStack {
                if editorConfig.showPicker {
                    Spacer()
                    Picker(selection: $editorConfig.numberOfSets,
                           label: EmptyView(), content: {
                        ForEach(0 ..< 21) { Text("\($0)") }
                    })
                    .background(Color.white).eraseToAnyView()
                    .labelsHidden()
                    .pickerStyle(DefaultPickerStyle())
                    .overlay(GeometryReader { geometry in
                        VStack(alignment: .trailing) {
                            Button(action: {
                                editorConfig.showPicker.toggle()
                            }) {
                                Text("Close")
                                    .font(.system(size: 16))
                                    .foregroundColor(.pink)
                                    .padding(.vertical)
                            }
                            Spacer()
                        }
                        .frame(width: geometry.size.width,
                               height: geometry.size.height - 50,
                               alignment: .trailing)
                        .padding()
                    }, alignment: .trailing)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .animation(.linear(duration: 0.3))
                } else {
                    EmptyView()
                }
            }
        }
    }
    private var addWorkStack: some View {
        VStack {
            Button("Add work", action: {
                editorConfig.presentSheet.toggle()
            })
            .padding()
            messageLabel
                .padding()
        }
    }
    private var workoutName: some View {
        TextField("name", text: $viewModel.name)
            .padding()
    }
    private var workoutDescription: some View {
        TextField("description", text: $viewModel.description)
            .padding()
    }
    private var saveButton: some View {
        switch viewModel.state {
        case .completeForm:
            return Button("Save", action: {
                self.viewModel.send(event: .onTapSave)
            }).disabled(false)
        default:
            return Button("Save", action: {}).disabled(true)
        }
    }
    private var messageLabel: some View {
        switch viewModel.state {
        case .savedSuccessFully:
            return Text("Success!!")
        case .errorSaving:
            return Text("Error!")
        default:
            return Text("Heres your result")
        }
    }
    private func list() -> some View {
        ForEach(viewModel.workout.intervals) { interval in
            Text("\(interval.intervalDescription) for \(interval.durationInSeconds) seconds")
        }
    }
    private func listItem(with interval: Interval) -> some View {
        VStack {
            HStack {
                Text(interval.intervalDescription)
                Text("\(interval.durationInSeconds)")
            }
        }.padding()
    }
}

struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView(viewModel: AddWorkoutViewModel())
    }
}
