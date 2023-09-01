import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var tablePlaced = false
    private var ballSunkSound: SCNAudioSource!
    private var sunkCups = [SCNNode]()
    private var planeNode: SCNNode?
    private let planeDetectorName = "plane detector"
    private var ballsThrown = 0
    private var cupsElim = 0
    private var bestScore = 80
    private var victorySound: SCNAudioSource!
    private var hard = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var bestScoreDefault = UserDefaults.standard

        if (bestScoreDefault.value(forKey: "BestScore") != nil) {
            print("loaded new best score")
            bestScore = bestScoreDefault.value(forKey: "BestScore")  as! NSInteger
        }
        //bestScoreDefault.setValue(80, forKey: "BestScore")
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        addPhysicsContactDelegate()
        sceneView.autoenablesDefaultLighting = true
        prefetchSounds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableHorizontalPlaneFinder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    private func prefetchSounds() {
        let victorySoundPath = "art.scnassets/victorySound.wav"
        victorySound = SCNAudioSource(fileNamed: victorySoundPath)
        victorySound.load()
        let sunkSoundPath = "art.scnassets/sunk.wav"
        ballSunkSound = SCNAudioSource(fileNamed: sunkSoundPath)
        ballSunkSound.load()
    }

    private func enablePhysics(to node: SCNNode) {
        enableSurfacePhysics(to: node)
        enableCupsPhysics(to: node)
    }
    
    private func updateCupsEliminated() {
        let elimName = "cupsEliminated"
        
        if let elimNode = sceneView.scene.rootNode.childNode(withName: elimName, recursively: true){
            print("successfully found elimination node")
            var text: SCNText = elimNode.geometry as! SCNText
            text.string = "Cups Eliminated: " + String(cupsElim) + "/10"
        }
        else {
            print("failed to find elim node")
        }
    }
    
    private func updateScore() {
        let scoreName = "score"
        
        if let scoreNode = sceneView.scene.rootNode.childNode(withName: scoreName, recursively: true) {
            print("successfully found score node")
            var text: SCNText = scoreNode.geometry as! SCNText
            text.string = "Balls Thrown: " + String(ballsThrown)      }
        else {
            print("failed to find score node")
        }
    }

    private func enableSurfacePhysics(to node: SCNNode) {
        let surfaceRestitution = CGFloat(1.3)
        let surfaceHeight = CGFloat(0.06)
        let surfaceWidth = CGFloat(1.0)
        let surfaceLength = CGFloat(1.5)
        let surfaceName = "table"
        let surfaceTopName = "top"

        if let surfaceNode = node.childNode(withName: surfaceName, recursively: true) {
            
            if let surfaceTopNode = node.childNode(withName: surfaceTopName, recursively: true) {
                let surfaceTopShape = SCNPhysicsShape(geometry: SCNBox(width: surfaceWidth, height: surfaceHeight, length: surfaceLength, chamferRadius: 0))
                let surfaceTopPhysics = SCNPhysicsBody(type: .static, shape: surfaceTopShape)
                surfaceTopPhysics.restitution = surfaceRestitution
                surfaceNode.physicsBody = surfaceTopPhysics
                surfaceNode.isHidden = false
                surfaceNode.opacity = 0.0
            }
        }
    }

    private func enableCupsPhysics(to node: SCNNode) {
        let bottomRestitution = CGFloat(0.0)
        let sideRestitution = CGFloat(0.1)
        let cupsName = "cups"
        let cupBottomName = "bottom"
        let cupSideName = "side"

        if let cupsNode = node.childNode(withName: cupsName, recursively: true) {
            for cup in cupsNode.childNodes {
                for child in cup.childNodes {
                    let shapeOptions = [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]
                    let childShape = SCNPhysicsShape(node: child, options: shapeOptions)
                    let childPhysics = SCNPhysicsBody(type: .static, shape: childShape)
                    if child.name == cupBottomName {
                        childPhysics.contactTestBitMask = Ball().categoryBitMask
                        childPhysics.restitution = bottomRestitution
                    } else if child.name == cupSideName {
                        if let geometry = child.geometry {
                            let material = SCNMaterial()
                            material.diffuse.contents = UIImage(named: "art.scnassets/Cornell-Big-Red-Logo-2002.jpg")
                            geometry.firstMaterial = material
                            geometry.materials.forEach({ $0.isDoubleSided = true })
                        }
                        childPhysics.restitution = sideRestitution
                    }
                    child.physicsBody = childPhysics
                }
            }
        }
    }


    private func addPhysicsContactDelegate() {
        sceneView.scene.physicsWorld.contactDelegate = self
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let cupBottom = contact.nodeB
        if let cup = cupBottom.parent {
            playBallSunkSound(toNode: cup)
            updateCupsEliminated()

            let ball = contact.nodeA
            if let ballPhysics = ball.physicsBody {
                ballPhysics.restitution = 0.0
            }
            hideCup(cup, ball)
        }
    }


    private func hideCup(_ cup: SCNNode, _ ball: SCNNode) {
        let shortFade = 0.5
        let longFade = 0.75

        func fade(_ node: SCNNode, duration: Double) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = duration
            node.opacity = 0.0
            SCNTransaction.commit()
        }

        func hide(_ node: SCNNode) {
            let hideTime = longFade
            SCNTransaction.begin()
            SCNTransaction.animationDuration = hideTime
            node.isHidden = true
            SCNTransaction.commit()
        }

        fade(cup, duration: shortFade)
        fade(ball, duration: longFade)
        hide(cup)
        hide(ball)
    }
    
    func playVictorySound(toNode node: SCNNode) {
        
        if (cupsElim == 10) {
            node.runAction(SCNAction.playAudio(victorySound, waitForCompletion: true))
        }
    }

    func playBallSunkSound(toNode node: SCNNode) {
        if !sunkCups.contains(node) {
            if (cupsElim <= 9){
                print("HELLO SOUNDD PLZ")
                sceneView.scene.rootNode.runAction(SCNAction.playAudio(ballSunkSound, waitForCompletion: true))
            }
            sunkCups.append(node)
            cupsElim+=1
            updateCupsEliminated()
        }
        
        if (cupsElim == 10) {
            
            playVictorySound(toNode: node)
            
            let winnerName = "winner"

            
            
            if let winnerNode = sceneView.scene.rootNode.childNode(withName: winnerName, recursively: true) {
                print("successfully found winner node")
                winnerNode.isHidden=false
            }
            else {
                print("failed to find score node")
            }
            
            if (bestScore > ballsThrown) {
                bestScore = ballsThrown
                
                var bestScoreDefault = UserDefaults.standard
                
                bestScoreDefault.setValue(bestScore, forKey: "BestScore")
                bestScoreDefault.synchronize()
                
                let bestScoreName = "bestScore"
                
                let newBestScoreName = "newBestScore"
                
                if let newBestScoreNode = sceneView.scene.rootNode.childNode(withName: newBestScoreName, recursively: true) {
                    print("successfully found newBestScore node")
                    newBestScoreNode.isHidden=false
                }
                
            }
            
        }
    }


    
    
    @IBAction func onViewTapped(_ sender: UITapGestureRecognizer) {
        if tablePlaced {
            ()
        } else {
            let tapLocation = sender.location(in: sceneView)
            let hits = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            if let hit = hits.first {
                placeCups(hit)
                tablePlaced = true
                
                let bestScoreName = "bestScore"
                
                if let bestScoreNode = sceneView.scene.rootNode.childNode(withName: bestScoreName, recursively: true) {
                    print("successfully found bestScore node")
                    let text: SCNText = bestScoreNode.geometry as! SCNText
                    text.string = "Best Score: " + String(bestScore)
                }
                disablePlaneFinder()
            }
        }
    }


    private func placeCups(_ hit: ARHitTestResult) {
        let planePosition = calcPlanePosition(from: hit)
        addCups(at: planePosition)
    }

    private func calcPlanePosition(from hit: ARHitTestResult) -> SCNVector3 {
        let transform = hit.worldTransform
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }

    private func addCups(at position: SCNVector3) {
        if let tableNode = createCupsAndAssets(at: position) {
            sceneView.scene.rootNode.addChildNode(tableNode)
        }
    }

    private func createCupsAndAssets(at position: SCNVector3) -> SCNNode? {
        guard let url = Bundle.main.url(forResource: "table", withExtension: "scn", subdirectory: "art.scnassets") else {
            return nil
        }
        guard let cupScene = SCNReferenceNode(url: url) else {
            return nil
        }

        cupScene.load()
        cupScene.position = position
        enablePhysics(to: cupScene)
        return cupScene
    }


    private func enableHorizontalPlaneFinder() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    private func disablePlaneFinder() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.enumerateChildNodes() {
            node, stop in
            if node.name == planeDetectorName {
                node.removeFromParentNode()
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // Create an SCNNode for a detect ARPlaneAnchor
        guard let _ = anchor as? ARPlaneAnchor else {
            return nil
        }
        planeNode = SCNNode()
        return planeNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))

        let planeMaterial = SCNMaterial()
        
        
        planeMaterial.diffuse.contents = UIImage(named: "art.scnassets/red_grid.png")
        plane.firstMaterial = planeMaterial

        let planeNode = SCNNode(geometry: plane)
        planeNode.name = planeDetectorName
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)

        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)

        node.addChildNode(planeNode)
    }
    
    func getAngleForSwipes(x : Double) -> Double {
        if x > 1.0 || x < -1.0
        {
            return atan(1.0/x)
        }
        else {
            return .pi/2 - atan(x)
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        
        if tablePlaced{
            if (sender.state == UIGestureRecognizer.State.ended) {
                ballsThrown += 1
                updateScore()
                
                let velocity = sender.velocity(in: sceneView)
                let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
                let slideMultiplier = magnitude / 200
                let slideFactor = 0.1 * slideMultiplier
                print(magnitude)
                let forceDirection = simd_make_float4(0,Float(getAngleForSwipes(x: Double(magnitude / velocity.x))),Float(getAngleForSwipes(x: Double(magnitude / velocity.y))),0)
                let ball = Ball()
                ball.hostViewController = self
                if let currFrame = sceneView.session.currentFrame {
                    let camera = currFrame.camera
                    ball.setPosition(in: sceneView)
                    ball.addToSceneRootNode(sceneView)
                    ball.launchBall(camera, forceDir: forceDirection, slideFactor: Float(slideFactor))
                }
                else{
                    ()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6, execute: randomizeBox)
            }
        }
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        hard = true
    }
    
    private func randomizeBox() {
        
        let boxNode = sceneView.scene.rootNode.childNode(withName: "box1", recursively: true)
        let summonLocationX = Float.random(in: -0.5..<0.5)
        let summonLocationY = Float.random(in: 0.2..<0.6)
        boxNode?.position = SCNVector3(summonLocationX, summonLocationY, 0.039)
        if(cupsElim >= 3 && hard) {
            let boxNode = sceneView.scene.rootNode.childNode(withName: "box2", recursively: true)
            let summonLocationX = Float.random(in: -0.5..<0.5)
            let summonLocationY = Float.random(in: 0.2..<0.6)
            boxNode?.position = SCNVector3(summonLocationX, summonLocationY, 0.06)
        }
        
        if(cupsElim >= 7 && hard) {
            let boxNode = sceneView.scene.rootNode.childNode(withName: "box3", recursively: true)
            let summonLocationX = Float.random(in: -0.5..<0.5)
            let summonLocationY = Float.random(in: 0.2..<0.6)
            boxNode?.position = SCNVector3(summonLocationX, summonLocationY, 0.05)
        }
    }
 

}
