import UIKit

class ButtonsViewController: UIViewController {

	@IBOutlet weak var winnerLabel: UILabel!
	@IBOutlet weak var randomLabel: UILabel!
	let buttonGame = ButtonGameService()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.generateNumber()
		buttonGame.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

	
	
	@IBAction func handleClick(_ sender: UIButton) {
		if sender.titleLabel?.text == self.randomLabel.text {
			print("correct")
			let name = buttonGame.myPeerId.displayName
			var data = [String:String]()
			if buttonGame.isHost {
				data["event"] = ButtonGameService.Event.HostAdd.rawValue
				buttonGame.didUpdate = false
			} else {
				data["event"] =  ButtonGameService.Event.Add.rawValue
			}
			data["data"] = name
			buttonGame.send(peerData: data)
//			self.generateNumber()
		} else {
			print("wrong")
		}
	}
}

extension ButtonsViewController: ButtonGameServiceDelegate {
	
	func addData(manager: ButtonGameService, dataString: String) {
		OperationQueue.main.addOperation {
			var data: [String:String] = ["event": ButtonGameService.Event.Update.rawValue]
			data ["data"] = dataString
			self.buttonGame.send(peerData: data)
			self.winnerLabel.text = dataString
			self.generateNumber()
		}
	}
	
	func generateNumber() {
		if self.buttonGame.isHost {
			let random = arc4random_uniform(8)+1
			self.randomLabel.text = String(random)
			var data = [String:String]()
			data["event"] = ButtonGameService.Event.Random.rawValue
			data["data"] = String(random)
			buttonGame.send(peerData: data)
		}
	}
	
	func updateData(manager: ButtonGameService, dataString: String) {
		OperationQueue.main.addOperation {
			self.winnerLabel.text = dataString
		}
	}
	
	func updateRandom(manager: ButtonGameService, dataString: String) {
		OperationQueue.main.addOperation {
			self.randomLabel.text = dataString
		}
	}
}
