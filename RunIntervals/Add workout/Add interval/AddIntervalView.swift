//
//  AddIntervalView.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/24.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import SwiftUI

struct EditorConfig {
    var showPicker = false
    var durationMinutes: Int = 0
    var durationSeconds: Int = 0
}

struct AddIntervalView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private(set) var viewModel: AddIntervalViewModel
    @State private var editorConfig = EditorConfig()
    var body: some View {
        content.eraseToAnyView()
            .overlay(DurationPicker(editorConfig: $editorConfig), alignment: .bottom)
            .environmentObject(viewModel)
    }
    private var content: some View {
        switch viewModel.state {
        case .addedIntervalToWorkout:
            self.presentationMode.wrappedValue.dismiss()
            return form.eraseToAnyView()
        default:
            return form.eraseToAnyView()
        }
    }
    private var form: some View {
        VStack(alignment: .leading) {
            backButton
            description
            Divider()
            Duration(editorConfig: $editorConfig)
            Divider()
            HStack {
                Spacer()
                saveButton.padding(.all)
                Spacer()
            }
            Spacer()
        }
        .padding()
        .eraseToAnyView()
    }
    private var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "backward")
        }.padding(.all)
    }
    private var description: some View {
        TextField("Interval Description: ie. Warmup",
                  text: $viewModel.intervalDescription)
            .padding(.all)
            .keyboardType(.alphabet)
    }
    struct Duration: View {
        @Binding var editorConfig: EditorConfig
        var body: some View {
            HStack {
                Button(action: {
                    editorConfig.showPicker.toggle()
                }) {
                    Text("Duration\nmin : sec")
                }
                .padding()
                Spacer()
                Text("\(editorConfig.durationMinutes) : \(editorConfig.durationSeconds)")
                Spacer()
            }
        }
    }
    struct DurationPicker: View {
        @Binding var editorConfig: EditorConfig
        @EnvironmentObject var viewModel: AddIntervalViewModel
        var body: some View {
            VStack {
                if editorConfig.showPicker {
                    Spacer()
                    HStack {
                        Picker(selection: $editorConfig.durationMinutes,
                               label: Text("minutes")
                                .foregroundColor(Color.red), content: {
                                    ForEach(0 ..< 60) { Text("\($0)") }
                                })
                            .background(Color.white).eraseToAnyView()
                            .frame(width: 100)
                            .clipped()
                        Picker(selection: $editorConfig.durationSeconds,
                               label: EmptyView(), content: {
                                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) {
                                    Text("\($0)")
                                }
                               })
                            .background(Color.white).eraseToAnyView()
                            .frame(width: 100)
                            .clipped()
                            .pickerStyle(DefaultPickerStyle())
                            .overlay(GeometryReader { geometry in
                                VStack(alignment: .trailing) {
                                    Button(action: {
                                        editorConfig.showPicker.toggle()
                                        viewModel.duration = (editorConfig.durationMinutes*60 + editorConfig.durationSeconds)
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
                    }
                    .frame(width: 200, alignment: .center)
                    .padding(.bottom, 20)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))
                    .animation(.linear(duration: 0.3))
                } else {
                    EmptyView()
                }
            }
        }
    }
    private var saveButton: some View {
        switch viewModel.state {
        case .completeForm:
            return Button("Save", action: {
                self.viewModel.send(event: .onTapSave)
            }).disabled(false)
        default:
            return Button("Save", action: {
                self.viewModel.send(event: .onTapSave)
            }).disabled(true)
        }
    }
}
struct AddIntervalView_Previews: PreviewProvider {
    static var previews: some View {
        AddIntervalView(viewModel: AddIntervalViewModel(Workout()))
    }
}
