//
//  ProgressView.swift
//  
//
//  Created by Higashihara Yoki on 2021/10/10.
//

import SwiftUI

struct ProgressView: UIViewRepresentable {
    @Binding var progress: Progress?
    var progressTintColor: UIColor

    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView()
        progressView.tintColor = progressTintColor
        
        return progressView
    }

    func updateUIView(_ uiView: UIProgressView, context: Context) {
        uiView.observedProgress = progress
    }
}


#if DEBUG
struct ProgressViewPreviews: PreviewProvider {
    static var previews: some View {
        ProgressView(progress: .constant(Progress(totalUnitCount: 100)),
                     progressTintColor: .blue)
            .previewLayout(.fixed(width: 300, height: 10))
    }
}
#endif
