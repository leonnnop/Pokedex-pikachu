

import UIKit
import ARKit
import SwiftySound

class ARViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var detectLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var backButton: UIButton!
    
    // 用于配置AR世界追踪
    // The Configuration of World Tracking
    let configuration = ARWorldTrackingConfiguration()
    var planeAnchor: ARPlaneAnchor!
    var planeNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Sound.stopAll()
        // 设置AR平面检测类型
        // set the plane detecing type of world tracking
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        addHandler()
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        reset()
    }
    
    func addHandler() {
        if planeAnchor != nil {
            addPortal(with: planeAnchor!.transform)
        }
    }
    
    func reset() {
        // 清除节点之前先停止AR会话，否则会crash
        // pause ar session before remove node, or will be crash
        self.sceneView.session.pause()
        
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        
        self.planeAnchor = nil
        self.addButton.isEnabled = false
        
        // 使用重置配置启动AR会话，场景将会被重置
        // Run AR session with reset options, then session will be reset
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
}

// MARK: - add model function
extension ARViewController {
    
    func addPortal(withHitTestResult result: ARHitTestResult) {
        addPortal(with: result.worldTransform)
    }
    
    func addPortal(with transform: matrix_float4x4) {
        guard let portalScene = SCNScene(named: "Model.scnassets/tjgc.scn") else {return}
        let portalNode = portalScene.rootNode.childNode(withName: "tjgc", recursively: false)!
        let newVector3 = SCNVector3.init(withTransform: transform)
        portalNode.position = SCNVector3.init(newVector3.x, newVector3.y, newVector3.z-1)
        sceneView.scene.rootNode.addChildNode(portalNode)
        
        self.addPlane(nodeName: "roof", portalNode: portalNode, imageName: "riverside_up")
        self.addPlane(nodeName: "floor", portalNode: portalNode, imageName: "riverside_down")
        self.addWalls(nodeName: "backWall", portalNode: portalNode, imageName: "riverside_north")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode, imageName: "riverside_west")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode, imageName: "riverside_east")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode, imageName: "riverside_south")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode, imageName: "riverside_south")
        self.addWalls(nodeName: "doorHeader", portalNode: portalNode, imageName: "riverside_up")
        self.addNode(nodeName: "pikachu", portalNode: portalNode, imageName: "")

    }
    
    fileprivate func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Model.scnassets/\(imageName).BMP")
        child?.renderingOrder = 200
    }
    
    fileprivate func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Model.scnassets/\(imageName).BMP")
        child?.renderingOrder = 200
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            // 设置渲染顺序，渲染顺序小的优先渲染，从而通过让优先渲染的节点透明使后面渲染的节点也透明
            // set the redering order, nodes with greater rendering orders are rendered last. We can let NodeA to be transparent and rendered first, so that the node rendered after NodeA will also be transparent.
            mask.renderingOrder = 150
            mask.geometry?.firstMaterial?.transparency = 0.00001
        }
    }
    
    fileprivate func addNode(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true)
        child?.renderingOrder = 200
    }
    
}

// MARK: - ARSCNViewDelegate implemention
extension ARViewController: ARSCNViewDelegate {
    
    // ARSCNView当检测到平面时会向其放置锚点，同时调用didAdd:anchor:代理方法
    // ARSCNView will add anchor when plane detected, the call didAdd:anchor: delegate function
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 如果检测到的是水平面，那么就是我们需要的，所以在此判断是否为水平面
        // Judge the plane if it is horizontal plane
        guard anchor is ARPlaneAnchor else {return}
        
        self.planeAnchor = anchor as? ARPlaneAnchor
        
        let plane = SCNPlane(width: CGFloat(self.planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.materials.first?.diffuse.contents = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
        
        self.planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        // 启用放置按钮, 显示可放置标签
        // Enable Add Button, and make remind label visiable.
        DispatchQueue.main.async {
            self.addButton.isEnabled = true
            self.detectLabel.isHidden = false
            self.detectLabel.text = "检测到平面，请点击放置按钮"         // "Plane Detected, Press Add button to add."
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            UIView.animate(withDuration: 1, animations: {
                self.detectLabel.isHidden = true
            })
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        
        self.planeAnchor = planeAnchor
        
        DispatchQueue.main.async {
            self.detectLabel.isHidden = false
            self.detectLabel.text = "已更新平面"         // "Plane Detected, Press Add button to add."
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            UIView.animate(withDuration: 1, animations: {
                self.detectLabel.isHidden = true
                
            })
        }
    }
    
}

