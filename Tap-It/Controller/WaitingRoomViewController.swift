import UIKit

class WaitingRoomViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var playButton: UIButton!
	var peersTuple:[(Int, String)]!
	var playerName:String! {
		didSet {
			self.initializeManager()
			self.data = [playerName]
		}
	}
	var manager = FigureGameManager()
	
	var data = [String]() {
		didSet {
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		self.generatePlayerName()
	}
	
	func initializeManager() {
		self.manager = FigureGameManager()
		self.manager.delegateWatingRomm = self
		self.manager.initPlayer(playerName: playerName!)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private func generatePlayerName() {
		let alert = UIAlertController(title: "Player Name", message: "Enter your name",
									  preferredStyle: UIAlertControllerStyle.alert)
		alert.addTextField { (textField: UITextField) in
			textField.placeholder = "player name"
			textField.textColor = .blue
			textField.clearButtonMode = .whileEditing
			textField.borderStyle = .roundedRect
		}
		let ok = UIAlertAction(title: "That's me!", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
			let textField = alert.textFields![0]
			if textField.text != nil && textField.text != "" {
				self.playerName = textField.text!
			}
		}
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "start" {
			if let dest = segue.destination as? FigureViewController {
				dest.gameManager = self.manager
				dest.peersTuple = self.peersTuple
			}
		}
	}
	
	@IBAction func handleClick(_ sender: UIButton) {
		sender.backgroundColor = .green
		self.manager.joinGame()
	}
}

extension WaitingRoomViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let peer = self.data[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = peer
		return cell
	}
}

extension WaitingRoomViewController: GameManagerWaitingRoomProtocol {
	
	func updatePeersList(_ peers: [(Int, String)]) {
		DispatchQueue.main.async {
			self.data = peers.map({ (_,name) -> String in
				return name
			})
			self.peersTuple = peers
		}
	}

	func callGameView() {
		performSegue(withIdentifier: "start", sender: nil)
	}

	func closeWaitingRoom() {
		dismiss(animated: true, completion: nil)
	}
}
