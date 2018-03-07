import UIKit

class ButtonsViewController: UIViewController {

	@IBOutlet weak var winnerLabel: UILabel!
	@IBOutlet weak var randomLabel: UILabel!
	let buttonGame = ButtonGameService()
	
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var button4: UIButton!
	@IBOutlet weak var button5: UIButton!
	@IBOutlet weak var button6: UIButton!
	@IBOutlet weak var button7: UIButton!
	@IBOutlet weak var button8: UIButton!
	
	var numbers = ["1","2","3","4","5","6","7","8"]
	
	override func viewDidLoad() {
        super.viewDidLoad()
//		self.generateNumber()
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
	
	func randomButtons() {
		let buttonArray = [button1, button2, button3, button4, button5, button6, button7, button8]
		for button in buttonArray {
			updateButton(button: button!)
		}
		numbers = ["1","2","3","4","5","6","7","8"]
	}
	
	func updateButton(button: UIButton) {
		let pos = Int(arc4random_uniform(UInt32(numbers.count)))
		button.titleLabel?.text = numbers[pos]
		numbers.remove(at: pos)
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
		OperationQueue.main.addOperation {
			if self.buttonGame.isHost {
				let random = arc4random_uniform(8)+1
				self.randomLabel.text = String(random)
				var data = [String:String]()
				data["event"] = ButtonGameService.Event.Random.rawValue
				data["data"] = String(random)
				self.buttonGame.send(peerData: data)
				self.randomButtons()
			}
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
			self.randomButtons()
		}
	}
}
