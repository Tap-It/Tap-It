import UIKit

class ButtonsViewController: UIViewController {

    let gameManager = GameManager()
    
	@IBOutlet weak var scoreTableView: UITableView!
	@IBOutlet weak var randomLabel: UILabel!
	
	@IBOutlet weak var button1: UIButton!
	@IBOutlet weak var button2: UIButton!
	@IBOutlet weak var button3: UIButton!
	@IBOutlet weak var button4: UIButton!
	@IBOutlet weak var button5: UIButton!
	@IBOutlet weak var button6: UIButton!
	@IBOutlet weak var button7: UIButton!
	@IBOutlet weak var button8: UIButton!
	
	var scoreBoard = [String]() {
		didSet {
			self.scoreTableView.reloadData()
		}
	}
	
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
	func updateScoreboard(scoreboard: [String]) {
		self.scoreBoard = scoreboard
	}
	
    func updateQuestion(question: String) {
        randomLabel.text = question
        updateButtons()
    }
}

extension ButtonsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.scoreBoard.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let score = self.scoreBoard[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = score
		return cell
	}
	
	
}
