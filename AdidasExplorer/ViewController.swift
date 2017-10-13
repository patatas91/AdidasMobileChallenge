//
//  ViewController.swift
//  AdidasExplorer
//
//  Created by Cristian Simon Moreno on 12/10/17.
//  Copyright © 2017 Cristian Simon Moreno. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    // Elementos storyboard
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var ball: UIButton!
    @IBOutlet weak var shoe: UIButton!
    
    // Anchors paneles 2D
    var anchorsPlanes: [ARAnchor] = []
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.ball.isEnabled = !self.isLoadingObject
                self.shoe.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // Cambio entre modelos
    var ballActive = false
    var shoeActive = false
    var inicio = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        self.sceneView.automaticallyUpdatesLighting = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // Pulsacion de pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitFeature = results.last else { return }
        let hitTransform = SCNMatrix4(hitFeature.worldTransform) 
        let hitPosition = SCNVector3Make(hitTransform.m41,
                                         hitTransform.m42,
                                         hitTransform.m43)
        // Creamos el anchor para el plano 2D
        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            let transform = simd_mul(currentFrame.camera.transform, translation)
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
            anchorsPlanes.append(anchor)
        }
        loadModel(hitPosition: hitPosition)
    }
    
    // Cargamos el modelo que corresponda
    func loadModel(hitPosition : SCNVector3) {
        //eliminamos otros nodos
        removeNodes()
        if (ballActive) {
            //BALL
            NSLog("CARGAR BALON");
            let model = BallModel()
            model.loadModal()
            let text_layer_ball = make2dNode(image: UIImage(named: "art.scnassets/letreros/text_ball.png")!, width: 0.64, height: 0.5)
            model.position = hitPosition
            text_layer_ball.position = hitPosition
            // Cargamos etiqueta y modelo
            self.sceneView.scene.rootNode.addChildNode(text_layer_ball)
            self.sceneView.scene.rootNode.addChildNode(model)
        } else if (shoeActive) {
            //SHOE
            NSLog("CARGAR ZAPATILLA");
            let model = ShoeModel()
            model.loadModal()
            let text_layer_shoe = make2dNode(image: UIImage(named: "art.scnassets/letreros/text_shoe.png")!, width: 0.64, height: 0.5)
            model.position = hitPosition
            text_layer_shoe.position = hitPosition
            // Cargamos etiqueta y modelo
            self.sceneView.scene.rootNode.addChildNode(text_layer_shoe)
            self.sceneView.scene.rootNode.addChildNode(model)
        } else {
            // Alerta si no se ha seleccionado que modelo hay que cargar
            let alert = UIAlertController(title: "Alerta", message: "Debe seleccionar primero el modelo que desea visualizar", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Crear nodo con imagen 2D
    func make2dNode(image: UIImage, width: CGFloat = 0.1, height: CGFloat = 0.1, z: Float = 0) -> SCNNode {
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        node.position = SCNVector3(node.position.x, node.position.y, node.position.z + z)
        return node
    }
    
    // Eliminar nodos
    func removeNodes() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            node.removeFromParentNode()
        }
    }
    
    // MARK: - Alerts
    
    // Poner alert cargando
    func putLoadAlert() {
        let alert = UIAlertController(title: nil, message: "Cargando...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    // Poner alert inicial
    func putInitAlert() {
        let alert = UIAlertController(title: nil, message: "Obteniendo imagen, situese en una zona con la iluminacion adecuada", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 4, y: 30, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    // Quitar alerts
    func removeLoadAlert() {
        dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user.
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
    }
    
    // MARK: - Private methods
    
    // Mensajes panel info
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            if (inicio == true) {
                removeLoadAlert()
                inicio = false
            }
            message = "Pulse la pantalla para poner un modelo."
            
        case .normal:
            message = "Pulse la pantalla para poner un modelo."
            
        case .notAvailable:
            message = "Tracking no disponible."
            
        case .limited(.excessiveMotion):
            message = "Tracking limitado - Mueva el dispositivo mas lentamente."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limitado - Use el dispositivo en una zona con mayor visibilidad o con mas iluminacion."
            
        case .limited(.initializing):
            putInitAlert()
            message = "Inicializando sesion AR."
            
        }
        
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }
    
    

}

