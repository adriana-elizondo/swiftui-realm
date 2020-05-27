//
//  AddIntervalView.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/24.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//

import SwiftUI

struct AddIntervalView: View {
    @ObservedObject private(set) var viewModel: AddWorkoutViewModel
    var body: some View {
        NavigationView {
            TextField("name", text: $viewModel.interval.intervalDescription)
                .padding(.all)
            Divider()
            TextField("Duration", text: "\($viewModel.interval.durationInSeconds)")
            .padding(.all)
        }
    }
}

struct AddIntervalView_Previews: PreviewProvider {
    static var previews: some View {
        AddIntervalView(viewModel: AddWorkoutViewModel())
    }
}
