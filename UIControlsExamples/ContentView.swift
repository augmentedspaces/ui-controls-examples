//
//  ContentView.swift
//  UIControlsExamples
//
//  Created by Nien Lam on 10/8/21.
//  Copyright © 2021 Line Break, LLC. All rights reserved.
//

import SwiftUI
import ARKit
import RealityKit
import Combine


// MARK: - View model for handling communication between the UI and ARView.
class ViewModel: ObservableObject {

    // Variables for tracking UI interaction.
    @Published var toggleValue = false

    @Published var sliderValue: Float = 0

    @Published var textValue: String = ""
    
    // Signals for button presses.
    // Add to enum for more signals.
    let uiSignal = PassthroughSubject<UISignal, Never>()
    enum UISignal {
        case buttonPressA
        case buttonPressB
    }
}


// MARK: - UI Layer.
struct ContentView : View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            // AR View.
            ARViewContainer(viewModel: viewModel)

            VStack(alignment: .leading, spacing: 16) {

                // Button A.
                Button {
                    viewModel.uiSignal.send(.buttonPressA)
                } label: {
                    buttonIcon("chevron.right.square", color: .green)
                }


                // Button B.
                Button {
                    viewModel.uiSignal.send(.buttonPressB)
                } label: {
                    buttonIcon("chevron.right.square", color: .yellow)
                }


                // Toggle.
                Button {
                    viewModel.toggleValue.toggle()
                    
                } label: {
                    buttonIcon("eyes.inverse", color: viewModel.toggleValue ? .blue : .red)
                }


                // Text field.
                TextField("Input Text", text: $viewModel.textValue)
                    .font(.system(size: 24))
                    .background(Color.black)
                    .frame(width: 120)


                // Slider.
                Slider(value: $viewModel.sliderValue, in: 0...100)
                    .frame(width: 120)

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .padding(.top, 100)
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }

    // Helper methods for rendering icon.
    func buttonIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .resizable()
            .padding(10)
            .frame(width: 44, height: 44)
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(5)
    }
}


// MARK: - AR View.
struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel
    
    func makeUIView(context: Context) -> ARView {
        SimpleARView(frame: .zero, viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class SimpleARView: ARView {
    var viewModel: ViewModel
    var arView: ARView { return self }
    var subscriptions = Set<AnyCancellable>()

    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
        
        setupEntities()
    }
        
    func setupScene() {
        // Setup world tracking and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]
        arView.session.run(configuration)
        
        // Called every frame.
        scene.subscribe(to: SceneEvents.Update.self) { event in
            self.renderLoop()
        }.store(in: &subscriptions)
        

        // Process UI signals.
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }.store(in: &subscriptions)

        
        // Process toggle value.
        viewModel.$toggleValue.sink { value in
            print("👇 Did press toggle button:", value)
        
        }.store(in: &subscriptions)


        // Process text value.
        viewModel.$textValue.sink { value in
            print("👇 Did change text:", value)

        }.store(in: &subscriptions)


        // Process slider value.
        viewModel.$sliderValue.sink { value in
            print("👇 Did change slider:", value)

        }.store(in: &subscriptions)
    }


    // Process UI signals.
    func processUISignal(_ signal: ViewModel.UISignal) {
        switch signal {
        case .buttonPressA:
            print("👇 Did press button A")

        case .buttonPressB:
            print("👇 Did press button B")

        }
    }


    func setupEntities() {

    }


    func renderLoop() {

    }
}
