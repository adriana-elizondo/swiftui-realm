//
//  Spinner.swift
//  RunIntervals
//
//  Created by Adriana Elizondo on 2020/5/22.
//  Copyright © 2020 Adriana Elizondo. All rights reserved.
//
import SwiftUI

struct Spinner: UIViewRepresentable {
    let isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
