import SwiftUI
import ARKit
import RealityKit
import Combine

class CustomARView: ARView, ObservableObject {
    @Published var breathIn = true  
    var timer: Timer?
    var scale: Float = 1.0
    var scaleUp = true
    private var cancellables: Set<AnyCancellable> = []

    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        subscribeToActionStream()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init() {
        self.init(frame: UIScreen.main.bounds)
//        subscribeToActionStream()
        placeSphere(ofcolor: .white)
    }

    func subscribeToActionStream() {
        ARManager.shared.actionStream
            .sink { [weak self] action in
                switch action {
                case .placeSphere(let color):
                    self?.placeSphere(ofcolor: color)
                case .removeAllAnchors:
                    self?.scene.anchors.removeAll()
                }
            }
            .store(in: &cancellables)
    }

    func configuration() {
        let config = ARWorldTrackingConfiguration()
        session.run(config)
    }

    func placeSphere(ofcolor color: Color) {
        let sphereMesh = MeshResource.generateSphere(radius: 0.2)
        let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
        let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])

        guard let frame = self.session.currentFrame else {
            print("AR session is not available")
            return
        }
    
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -2.0
        let transform = simd_mul(frame.camera.transform, translation)
    
        let anchor = AnchorEntity(world: transform)
        anchor.addChild(sphereEntity)
        scene.addAnchor(anchor)

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self, weak sphereEntity] _ in
            guard let self = self else { return }
            if self.scaleUp {
                self.scale += 0.0032
                if self.scale >= 2.0 {
                    self.scaleUp = false
                    self.breathIn = false
                }
            } else {
                self.scale -= 0.005
                if self.scale <= 1.0 {
                    self.scaleUp = true
                    self.breathIn = true
                }
            }
            sphereEntity?.scale = SIMD3<Float>(repeating: self.scale)
        }
    }
}

