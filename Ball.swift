import ARKit

class Ball: SCNNode {
    private let radius = CGFloat(0.02)
    private let initialPosition = SCNVector3(x: 0, y: -0.05, z: -0.2)
    private let friction = CGFloat(0.05)
    weak var hostViewController: ViewController?

    override init() {
        super.init()
        createBall()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }


    private func createBall() {
        let ballName = "ball"
        self.name = ballName

        let geometry = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/Cornell-Big-Red-Logo-2002.jpg")
        geometry.firstMaterial = material
        self.geometry = geometry

        let physicsShape = SCNPhysicsShape(geometry: geometry)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody.rollingFriction = friction
        self.physicsBody = physicsBody
    }

    public func setPosition(in sceneView: ARSCNView) {
        if let pov = sceneView.pointOfView {
            setCoordinates(node: self, withPosition: initialPosition, relativeTo: pov)
        }
    }

    public func addToSceneRootNode(_ sceneView: ARSCNView) {
        sceneView.scene.rootNode.addChildNode(self)
    }

    
    public func launchBall(_ camera: ARCamera, forceDir: simd_float4, slideFactor: Float) {
            let rotation = simd_mul(camera.transform, forceDir)
            let scaling = SCNFloat(slideFactor)
       
            let forceVector = SCNVector3Make(rotation.x * scaling / 2, rotation.y * scaling / 3 + 1.6, rotation.z * scaling )
            print(forceVector)
            if let ballPhysics = self.physicsBody {
                ballPhysics.applyForce(forceVector, asImpulse: true)
            }
        }


    private func setCoordinates(node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        let translatedPositionAndOrientation = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(translatedPositionAndOrientation)
    }
}
