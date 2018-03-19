import UIKit

class WaitingRoomViewController: UIViewController {

	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	var playersSlots = [UIView]()
	var playersViews = [UIView]()
	var hasLayoutSlots = false
	var chosenImages = Set<Int>()

	var playerName:String! {
		didSet {
			self.initializeManager()
			self.players = [(1,playerName)]
		}
	}
	var manager = FigureGameManager()
	
	var players = [(Int, String)]() {
		willSet {
			for view in self.playersViews {
				view.removeFromSuperview()
			}
		}
		didSet {
			for i in 0..<self.players.count {
				self.addPlayerToView(name: self.players[i].1, imageNum:self.players[i].0, slot: i)
			}
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		let gradientLayer = CAGradientLayer()
		let topColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
		let bottomColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
		gradientLayer.colors = [topColor, bottomColor]
		gradientLayer.frame = view.frame
		view.layer.insertSublayer(gradientLayer, at: 0)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		self.generatePlayerName(message: "enter your name")
	}
	
	override func viewDidLayoutSubviews() {
		if !self.hasLayoutSlots {
			self.generatePlayersSlot(numOfPlayers: 8)
		}
	}
	
	private func addPlayerToView(name:String, imageNum:Int, slot:Int) {

		let playerSlot = self.playersSlots[slot]
		
		let playerView = UIView(frame: playerSlot.frame)

		let thumbRatio = CGFloat(0.75)
		let thumbSize = CGSize(width: playerView.frame.size.height * thumbRatio, height: playerView.frame.size.height * thumbRatio)
		let thumbOrigin = CGPoint(x: 20.0, y: (playerView.frame.size.height / 2) - (thumbSize.height / 2))
		let playerThumb = UIImageView(frame: CGRect(origin: thumbOrigin, size: thumbSize))
		let imageName = "figure_\(imageNum)"
		playerThumb.image = UIImage(named: imageName)
		playerThumb.contentMode = .scaleAspectFit
		
		let labelSize = CGSize(width: (playerView.frame.width) - (playerThumb.frame.origin.x + playerThumb.frame.size.width + 20.0) * 0.5, height: playerThumb.frame.size.height)
		let labelOrigin = CGPoint(x: (playerThumb.frame.origin.x + playerThumb.frame.size.width + 20.0), y: playerThumb.frame.origin.y)
		let playerNameLabel = UILabel(frame: CGRect(origin: labelOrigin, size: labelSize))
		let customFont = UIFont(name: "American Typewriter", size: 17.0)
		playerNameLabel.text = name
		playerNameLabel.font = customFont
		playerNameLabel.textColor = .black
		playerNameLabel.numberOfLines = 1
		
		playerView.addSubview(playerThumb)
		playerView.addSubview(playerNameLabel)
		self.playersViews.append(playerView)
		self.view.addSubview(playerView)
	}
	
	private func generatePlayersSlot(numOfPlayers:Int) {
		let startOrigin = CGPoint(x: 0.0, y: (self.titleLabel.frame.origin.y + self.titleLabel.frame.height + 10))
		let playersViewSize = CGSize(width: self.view.frame.size.width, height: (((self.startButton.frame.origin.y) - (self.titleLabel.frame.origin.y + self.titleLabel.frame.height)) / CGFloat(numOfPlayers)) - 1)
		var playerViewRect = CGRect(origin: startOrigin, size: playersViewSize)
		
		for _ in 0..<numOfPlayers {
			
			let playerView = UIView(frame: playerViewRect)

			let playerViewColor = UIColor(red: 245.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
			playerView.backgroundColor = playerViewColor
			
			self.playersSlots.append(playerView)
			self.view.addSubview(playerView)
			playerViewRect.origin.y += playerViewRect.size.height + 1
		}
		self.hasLayoutSlots = true
	}
	
	func initializeManager() {
		self.manager = FigureGameManager()
		self.manager.delegateWatingRomm = self
		self.manager.initPlayer(playerName: playerName!)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private func generatePlayerName(message: String) {
		let alert = UIAlertController(title: "Player Name", message: message,
									  preferredStyle: UIAlertControllerStyle.alert)
		alert.addTextField { (textField: UITextField) in
			textField.textColor = .blue
			textField.clearButtonMode = .whileEditing
			textField.borderStyle = .roundedRect
		}
		let ok = UIAlertAction(title: "That's me!", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
			let textField = alert.textFields![0]
			if textField.text != nil && textField.text != "" {
				self.playerName = textField.text!
			} else {
				self.generatePlayerName(message: "You must enter a name")
			}
		}
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "start" {
			if let dest = segue.destination as? FigureViewController {
				dest.gameManager = self.manager
				dest.numOfPeers = self.players.count
			}
		}
	}
	
	@IBAction func handleClick(_ sender: UIButton) {
		sender.titleLabel?.lineBreakMode = .byWordWrapping
		sender.titleLabel?.textAlignment = .center
		sender.setTitle("Ready!\n (waiting for players)", for: .normal)
		self.manager.joinGame()
	}
}

extension WaitingRoomViewController: GameManagerWaitingRoomProtocol {
	
	func updatePeersList(_ peers: [(Int, String)]) {
		DispatchQueue.main.async {
			self.players = peers
		}
	}

	func callGameView() {
		performSegue(withIdentifier: "start", sender: nil)
	}

	func closeWaitingRoom() {
		dismiss(animated: true, completion: nil)
	}
}
