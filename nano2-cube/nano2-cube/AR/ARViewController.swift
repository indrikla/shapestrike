//
//  ARViewController.swift
//  nano2-cube
//
//  Created by Risa on 26/05/24.
//

import SwiftUI

struct ARViewContainer: UIViewControllerRepresentable {
    @Binding var isBrushPressing: Bool
    let viewController : ViewController
    @Binding var hitCount: Int
    
    func makeUIViewController(context: Context) -> ViewController {
        viewController.isBrushPressing = isBrushPressing
        viewController.hitCount = $hitCount
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.isBrushPressing = isBrushPressing
    }
}
