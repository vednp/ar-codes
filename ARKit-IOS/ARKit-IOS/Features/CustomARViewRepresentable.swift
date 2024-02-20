//
//  CustomARViewRepresentable.swift
//  ARKit-IOS
//
//  Created by Ved Pahune on 18/02/24.
//

import SwiftUI

struct CustomARViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView(frame: CGRect())
    }
    func updateUIView(_ uiView: CustomARView, context: Context) {}
}
