import Foundation

protocol FigureProtocol {
    func updateDeck(_ card: Card)
    func updatePlayerCard(_ card: Card)
}

protocol FigureServiceProtocol {
    func send(_ data: [String:Any])
    func send(deck: [Card])
    func setDelegate(_ gameManager: FigureGameManager)
    func getName() -> String
	func shouldStartGame()
	func stopAdvertising()
}

protocol GameManagerWaitingRoomProtocol {
	func updatePeersList(_ peers:[String])
	func closeWaitingRoom()
	func callGameView()
}

enum Event: Int {
	case Card = 1,
    Click = 2,
	Update = 3,
	Score = 4,
	Deck = 5,
	AddPeer = 6,
	RemovePeer = 7,
	Peers = 8,
	JoinGame = 9,
	Startgame = 10
}

class FigureGameManager {
    
    var deck = [Card]()
	var currentCard:Int = 0
    var question: String!
    var delegate: FigureProtocol?
    let service: FigureServiceProtocol
    var scoreBoard = Scoreboard()
    var backupScore = [String:Int]()
	var delegateWatingRomm: GameManagerWaitingRoomProtocol?
	
//	var allPeers = [String]()
	
	init(playerName: String) {
		self.service = FigureGameService(playerName: playerName)
        self.service.setDelegate(self)
        self.addPlayer(player: service.getName())
    }
    
    func checkAnswer(_ answer: String) {
        if answer == question {
            // get my name from the gameservice
//            let name = service.getName()
//            var data = [String:String]()
//            data["event"] = Event.Click.rawValue
//            data["data"] = name
//            service.send(data)
        } else {
            print("wrong. blocked!")
        }
    }
	
	func shouldStartGame() {
		self.service.shouldStartGame()
		self.service.stopAdvertising()
	}
	
	private func distributeCard(players: [Player]) {
		for player in players {
			player.cards.append(self.currentCard)

			var data = [String:Any]()
			data["event"] = Event.Card.rawValue
			data["data"] = player
			
			service.send(data)

			self.currentCard += 1
		}
	}
	
	func joinGame() {
		var data = [String:Any]()
		data["event"] = Event.JoinGame.rawValue
		data["data"] = self.service.getName()
		service.send(data)
	}
	
	func checkStartGame() {
		if self.scoreBoard.hasEverybodyJoined() {
			// create an event to startGame
			var data = [String:Int]()
			data["event"] = Event.Startgame.rawValue
			service.send(data)
		}
	}
	
	private func updateDeckCard(players: [Player]) {
		var data = [String:Int]()
		data["event"] = Event.Deck.rawValue
		data["data"] = currentCard
		service.send(data)
		
		self.currentCard += 1
	}

    func randomButtons() -> [String] {
        var answers = ["1","2","3","4","5","6","7","8"]
        var numbers = [String]()
        while answers.count > 0 {
            let pos = Int(arc4random_uniform(UInt32(answers.count)))
            numbers.append(answers[pos])
            answers.remove(at: pos)
        }
        return numbers
    }
    
    private func updateScore(winner: String) {
//        if self.scoreBoard.keys.contains(winner) {
//            self.scoreBoard[winner] = self.scoreBoard[winner]! + 1
//        }
    }
}

extension FigureGameManager: FigureGameServiceDelegate {
    
    func addPlayer(player: String) {
		self.scoreBoard.addPlayer(name: player)
		let players = self.scoreBoard.players
		let names = players.map { (player) -> String in
			return player.name
		}
		let data:[String:Any] = ["event":Event.Peers.rawValue , "data":names]
//		let data:[String:Any] = ["event":Event.AddPeer.rawValue , "data":player]
		self.service.send(data)
    }
    
    func removePlayer(player: String) {
		self.scoreBoard.deletePlayer(name: player)
		let players = self.scoreBoard.players
		let names = players.map { (player) -> String in
			return player.name
		}
		let data:[String:Any] = ["event":Event.Peers.rawValue , "data":names]
//		let data:[String:Any] = ["event":Event.RemovePeer.rawValue , "data":player]
		self.service.send(data)
    }
    
    func receive(_ data: Any) {
        if let data = data as? [Card] {
            deck = data
        }
		
		if let data = data as? [String:Any] {
			let event = data["event"] as! Int
			if event == Event.Peers.rawValue, let peers = data["data"] as? [String] {
				self.delegateWatingRomm?.updatePeersList(peers)
				// call delegate method
			}
			if event == Event.JoinGame.rawValue, let peer = data["data"] as? String {
				self.scoreBoard.playerIsJoining(playerName: peer)
				self.checkStartGame()
			}
		}
		
		if let data = data as? [String:Int] {
			let event = data["event"]!
			
			if event == Event.Card.rawValue {
				let card = data["data"]!
				delegate?.updatePlayerCard(deck[card])
			}
			if event == Event.Deck.rawValue {
				let card = data["data"]!
				delegate?.updateDeck(deck[card])
			}
			if event == Event.Startgame.rawValue {
				delegateWatingRomm?.callGameView()
			}
		}
    }
    
    func startGame() {
        createDeck(order: 7)
		service.send(deck: deck)
		self.distributeCard(players: self.scoreBoard.players)
		self.updateDeckCard(players: self.scoreBoard.players)
    }
	
	func lostHost() {
		self.delegateWatingRomm?.closeWaitingRoom()
	}
}


extension FigureGameManager {
	
	func createDeck(order p:Int) {
		
		let min_factor = p

		for i in 0..<p {
			var tempCard = [Int]()
			for j in 0..<p { tempCard.append((i * p + j)) }
			tempCard.append(p * p)
			var tempSet = Set<Int>()
			for item in tempCard { tempSet.insert(item) }
			let card = Card(array: Array(tempSet))
			deck.append(card)
		}
		
		for i in 0..<min_factor {
			for j in 0..<p {
				var tempCard = [Int]()
				for k in 0..<p { tempCard.append((k * p + (j + i * k) % p)) }
				tempCard.append(p * p + 1 + i)
				var tempSet = Set<Int>()
				for item in tempCard { tempSet.insert(item) }
				let card = Card(array: Array(tempSet))
				deck.append(card)
			}
		}
		
		var tempCard = [Int]()
		for i in 0..<(min_factor + 1) { tempCard.append((p * p + i)) }
		var tempSet = Set<Int>()
		for item in tempCard { tempSet.insert(item) }
		let card = Card(array: Array(tempSet))
		deck.append(card)
		self.deck = deck.shuffled()
	}
}


extension MutableCollection {
	/// Shuffles the contents of this collection.
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

extension Sequence {
	/// Returns an array with the contents of this sequence, shuffled.
	func shuffled() -> [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}






