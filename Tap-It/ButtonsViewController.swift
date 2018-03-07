import UIKit

class ButtonsViewController: UIViewController {

	@IBOutlet weak var winnerLabel: UILabel!
	@IBOutlet weak var randomLabel: UILabel!
	let buttonGame = ButtonGameService()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.generateNumber()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func generateNumber() {
		let random = arc4random_uniform(8)+1
		self.randomLabel.text = String(random)
	}
	
	
	@IBAction func handleClick(_ sender: UIButton) {
		if sender.titleLabel?.text == self.randomLabel.text {
			print("correct")
		} else {
			print("wrong")
		}
		self.generateNumber()
	}
}

extension ButtonsViewController: ButtonGameServiceDelegate {
	
	func addData(manager: ButtonGameService, dataString: String) {
		OperationQueue.main.addOperation {
			var data: [String:String] = ["event": ColorServiceManager.Event.Update.rawValue]
			data ["data"] = dataString
			self.buttonGame.send(peerData: data)
			self.winnerLabel.text = dataString
		}
	}
	
	func updateData(manager: ButtonGameService, dataString: String) {
		OperationQueue.main.addOperation {
			self.winnerLabel.text = dataString
		}
	}
}
