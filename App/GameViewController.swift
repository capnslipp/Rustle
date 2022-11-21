// Rustle
// @author: Slipp Douglas Thompson

import UIKit
import SceneKit



// MARK: - Class

class GameViewController : UIViewController
{
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// create a new scene
		let scene = SCNScene()
		
		// create and add a camera to the scene
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		scene.rootNode.addChildNode(cameraNode)
		
		// place the camera
		cameraNode.position = SCNVector3(0, 0, 15);
		
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = {
			let l = SCNLight()
			l.type = .omni
			return l
		}()
		lightNode.position = SCNVector3(0, 10, 10)
		scene.rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = {
			let l = SCNLight()
			l.type = .ambient
			l.color = UIColor.darkGray
			return l
		}()
		scene.rootNode.addChildNode(ambientLightNode)
		
		// retrieve the SCNView
		let scnView = self.view! as! SCNView
		
		// set the scene to the view
		scnView.scene = scene
		
		// allows the user to manipulate the camera
		scnView.allowsCameraControl = true
			
		// show statistics such as fps and timing information
		scnView.showsStatistics = true

		// configure the view
		scnView.backgroundColor = UIColor.black
		
		// add a tap gesture recognizer
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
		var gestureRecognizers: [UIGestureRecognizer] = scnView.gestureRecognizers ?? []
		gestureRecognizers.append(tapGesture)
		scnView.gestureRecognizers = gestureRecognizers
	}

	@IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer)
	{
		// retrieve the SCNView
		let scnView = self.view! as! SCNView
		
		// check what nodes are tapped
		let p = gestureRecognizer.location(in: scnView)
		let hitResults = scnView.hitTest(p)
		
		// retrieved the first clicked object
		if let result = hitResults.first {
			// get its material
			let material = result.node.geometry?.firstMaterial
			
			// highlight it
			SCNTransaction.begin()
			defer { SCNTransaction.commit() }
			SCNTransaction.animationDuration = 0.5
			
			material?.emission.contents = UIColor.red
			
			// on completion - unhighlight
			SCNTransaction.completionBlock = {
				SCNTransaction.begin()
				defer { SCNTransaction.commit() }
				SCNTransaction.animationDuration = 0.5
				
				material?.emission.contents = UIColor.black
			}
		}
	}
	
	override var shouldAutorotate: Bool { true }
	
	override var prefersStatusBarHidden: Bool { true }
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}

	override func  didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}


}
