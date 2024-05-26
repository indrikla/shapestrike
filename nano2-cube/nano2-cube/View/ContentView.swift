//
//  ContentView.swift
//  nano2-cube
//
//  Created by Risa on 26/05/24.
//

import SwiftUI

struct ContentView: View {
    
    let viewController = ARManager.shared
    let drawingService = DrawingService()
    let arViewController = ViewController()
    @State var selectedColor = Color.blue
    @State private var isBrushPressing = false
    @State private var isBulletTapped = false
    @State private var hitCount = 0
    
    var body: some View {
        ZStack(content: {
            ARViewContainer(isBrushPressing: $isBrushPressing, viewController: arViewController, hitCount: $hitCount)
                .edgesIgnoringSafeArea(.all)

            Image("targetPoint")

            HStack {
                Text(String(drawingService.geometryNodes.count) + " Cubes")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                Spacer()
                VStack(alignment: .center, spacing: 40) {

                    IconButton(imageName: "shoot", iconSize: 35, buttonFill: true, label: "shoot") {
                    }
                    .onLongPressGesture(minimumDuration: 0.1,
                                        maximumDistance: .infinity,
                                        pressing: { isPressing in
                        self.isBrushPressing = isPressing
                                }, perform: {})
                                .padding()

                }
                .padding(16)
            }
        })
    }
}

#Preview {
    ContentView()
}
