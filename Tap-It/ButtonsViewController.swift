import UIKit

class ButtonsViewController: UIViewController {

    let gameManager = GameManager()
    
	@IBOutlet weak var winnerLabel: UILabel!
	@IBOutlet weak var randomLabel: UILabel!
	
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var button4: UIButton!
	@IBOutlet weak var button5: UIButton!
	@IBOutlet weak var button6: UIButton!
	@IBOutlet weak var button7: UIButton!
	@IBOutlet weak var button8: UIButton!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		gameManager.delegate = self
        self.updateButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func handleClick(_ sender: UIButton) {
        if let text = sender.titleLabel?.text {
            gameManager.checkAnswer(text)
        }
	}
		
	func updateButtons() {
        let labels = gameManager.randomButtons()
        button1.setTitle(labels[0], for: .normal)
        button2.setTitle(labels[1], for: .normal)
        button3.setTitle(labels[2], for: .normal)
        button4.setTitle(labels[3], for: .normal)
        button5.setTitle(labels[4], for: .normal)
        button6.setTitle(labels[5], for: .normal)
        button7.setTitle(labels[6], for: .normal)
        button8.setTitle(labels[7], for: .normal)
	}
}

extension ButtonsViewController: GameManagerProtocol {
    func updateWinner(dataString: String) {
        winnerLabel.text = dataString
    }
    
    
    
}

//extension ButtonsViewController: ButtonGameServiceDelegate {
//
//    func addData(manager: ButtonGameService, dataString: String) {
//        OperationQueue.main.addOperation {
//            var data: [String:String] = ["event": ButtonGameService.Event.Update.rawValue]
//            data ["data"] = dataString
//            self.buttonGame.send(peerData: data)
//            self.winnerLabel.text = dataString
//            self.generateNumber()
//        }
//    }
//
//    func generateNumber() {
//        OperationQueue.main.addOperation {
//            if self.buttonGame.isHost {
//                let random = arc4random_uniform(8)+1
//                self.randomLabel.text = String(random)
//                var data = [String:String]()
//                data["event"] = ButtonGameService.Event.Random.rawValue
//                data["data"] = String(random)
//                self.buttonGame.send(peerData: data)
//                self.randomButtons()
//            }
//        }
//    }
//
//    func updateData(manager: ButtonGameService, dataString: String) {
//        OperationQueue.main.addOperation {
//            self.winnerLabel.text = dataString
//        }
//    }
//
//    func updateRandom(manager: ButtonGameService, dataString: String) {
//        OperationQueue.main.addOperation {
//            self.randomLabel.text = dataString
//            self.randomButtons()
//        }
//    }
//}

