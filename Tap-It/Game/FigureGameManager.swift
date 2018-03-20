import Foundation

protocol FigureProtocol {
    func updateDeck(_ card: Card)
	func updatePlayerCard(_ card: Card, _ gotAnswer: Bool)
	func updateTopScore(_ rank:[(String, Int)])
	func updateDeckCount(_ total: Int)
	func updatePlayerScore(_ score: Int)
	func updateCounter(_ second: Int)
    func blockPlayer()
	func gameOver(winner:String, winCount:Int, playerPos:String, playerCount:Int)
}

protocol FigureServiceProtocol {
    func sendBlob(_ data: [String:Any])
    func sendBlobb(_ data: Data)
    func send(deck: [Card])
	func send(peerData: [String:Any])
    func setDelegate(_ gameManager: FigureGameManager)
    func getName() -> String
	func shouldStartGame()
	func stopAdvertising()
	func getHashFromPeer() -> Int
	func restartGame()
}

protocol GameManagerWaitingRoomProtocol {
	func updatePeersList(_ peers:[(Int, String)])
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
	Startgame = 10,
	PlayerId = 11,
	Cards = 12,
	Ready = 13,
	Seconds = 14,
	GameOver = 15
}

class FigureGameManager {
    
    var deck = [Card]()
	var currentCard:Int = 0
    var currentDeckCard:Int = 0
    var currentPlayerCard:Int = 0
	var previousDeckCard: Int = 0
    var delegate: FigureProtocol?
    var service: FigureServiceProtocol!
    var scoreBoard = Scoreboard()
    var backupScore = [String:Int]()
	var delegateWatingRomm: GameManagerWaitingRoomProtocol?
	var myGameId:Int = 0
	var peers = [(Int, String)]()
	var numOfPeersReady = 0
	var counter = 3

	func initPlayer(playerName: String) {
		self.service = FigureGameService(playerName: playerName)
        self.service.setDelegate(self)
		self.addPlayer(name: service.getName(), serviceId: self.service.getHashFromPeer())
    }
	
    func checkAnswer(_ answer: Int) {
        
        let deckFigures = deck[currentDeckCard].face.map { (figure) -> Int in
            return figure.imageNumber
        }
        let playerFigures = deck[currentPlayerCard].face.map { (figure) -> Int in
            return figure.imageNumber
        }

        if deckFigures.contains(answer) && playerFigures.contains(answer) {
			let event:UInt8 = UInt8(Event.Click.rawValue)
			let card:UInt8 = UInt8(self.currentDeckCard)
			let peer:UInt8 = UInt8(self.myGameId)
			let data = Data(bytes: [event,card,peer])
			self.service.sendBlobb(data)
            print("got it!")
        } else {
            delegate?.blockPlayer()
            print("wrong. blocked!")
        }
    }
	
	func restartGame() {
		self.service.restartGame()
	}
	
	func shouldStartGame() {
		self.service.shouldStartGame()
		self.service.stopAdvertising()
	}
	
	func shouldStartCountdown() {
		
		if self.numOfPeersReady == self.scoreBoard.players.count {
			Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
				let event:UInt8 = UInt8(Event.Seconds.rawValue)
				let second:UInt8 = UInt8(self.counter)
				let data = Data(bytes: [event,second])
				self.service.sendBlobb(data)
				self.counter -= 1
				if self.counter == -1 {
					timer.invalidate()
				}
			})
		}
	}
	
	func informReady() {
		let event:UInt8 = UInt8(Event.Ready.rawValue)
		let peer:UInt8 = UInt8(self.myGameId)
		let data = Data(bytes: [event,peer])
		self.service.sendBlobb(data)
	}
	
	private func runDeck(players: [Player]) {
		let event = UInt8(Event.Cards.rawValue)
		for player in players {
			player.cards.append(self.currentCard)
			self.currentCard += 1
		}
		let deckCard = UInt8(self.currentCard)
		let cardsInDeck = self.deck.count - currentCard
		print(cardsInDeck)
		if Int(cardsInDeck) == 0 {
			let event:UInt8 = UInt8(Event.GameOver.rawValue)
			var data = Data(bytes: [event])
			for player in self.scoreBoard.players {
				let id = UInt8(player.id)
				let numPlayerCards = UInt8(player.cards.count)
				data.append(contentsOf: [id, numPlayerCards])
			}
			service.sendBlobb(data)
			return
		}
		let cardsInDeckUInt = UInt8(cardsInDeck)
		var data = Data(bytes: [event, deckCard, cardsInDeckUInt])
		for player in self.scoreBoard.players {
			let id = UInt8(player.id)
			let playerCard = UInt8(player.cards.last!)
			let numPlayerCards = UInt8(player.cards.count)
			data.append(contentsOf: [id, playerCard, numPlayerCards])
		}
		service.sendBlobb(data)
	}
	
	private func distributeCard(players: [Player]) {
		for player in players {
			player.cards.append(self.currentCard)
			var data = [String:Any]()
			data["event"] = Event.Card.rawValue
			data["data"] = player
			service.sendBlob(data)
			self.currentCard += 1
		}
	}
	
	func joinGame() {
		var data = [String:Any]()
		data["event"] = Event.JoinGame.rawValue
		data["data"] = self.service.getHashFromPeer()
		service.send(peerData: data)
	}
	
	func checkStartGame() {
		self.numOfPeersReady += 1
		if self.scoreBoard.hasEverybodyJoined() {
			var data = [String:Int]()
			data["event"] = Event.Startgame.rawValue
			service.send(peerData: data)
		}
	}
	
	private func updateDeckCard(players: [Player]) {
		var data = [String:Int]()
		data["event"] = Event.Deck.rawValue
		data["data"] = currentCard
		service.sendBlob(data)
	}
	
	private func readPlayerData(_ data:Data) {
		var counter = 0
		let iterator = 3
		while data.count > (counter + iterator + 2) {
			counter = counter + iterator
			let id = Int(data[counter])
			if self.myGameId == id {
				let card = Int(data[counter + 1])
				self.currentPlayerCard = card
				let gotAnswer = self.currentPlayerCard == previousDeckCard

				delegate?.updatePlayerCard(deck[card], gotAnswer)
				let score = Int(data[counter+2])
				delegate?.updatePlayerScore(score)
			}
		}
	}
	
	private func readRank(_ data:Data) {
		var counter = 0
		let iterator = 3
		var rank = [(String, Int)]()
		while data.count > (counter + iterator + 2) {
			counter = counter + iterator
			let dataId = Int(data[counter])
			let score = Int(data[counter + 2])
			let player = self.peers.filter({ (id,_) -> Bool in
				id == dataId
			})
			let name = player.first!.1
			rank.append((name, score))
		}
		let sorted = rank.sorted { (player1, player2) -> Bool in
			return player1.1 >= player2.1
		}
		self.delegate?.updateTopScore(sorted)
	}
}

extension FigureGameManager: FigureGameServiceDelegate {

	func addPlayer(name: String, serviceId:Int) {
		if let newId = self.scoreBoard.addPlayer(name: name, serviceId: serviceId) {
			let data:[String:Int] = ["event":Event.PlayerId.rawValue, "data":newId, "peer":serviceId]
			self.service.send(peerData: data)
		}
		let players = self.scoreBoard.players
		let ids = players.map { (player) -> Int in
			return player.id
		}
		let names = players.map { (player) -> String in
			return player.name
		}
		let dataa:[String:Any] = ["event":Event.Peers.rawValue, "ids":ids, "names":names]
		self.service.send(peerData: dataa)
    }
    
    func removePlayer(serviceId: Int) {
		self.scoreBoard.deletePlayer(serviceId: serviceId)
		let players = self.scoreBoard.players
		let names = players.map { (player) -> String in
			return player.name
		}

		let ids = players.map { (player) -> Int in
			return player.id
		}
		let data:[String:Any] = ["event":Event.Peers.rawValue, "ids":ids, "names":names]
		self.service.send(peerData: data)
    }
	
	func handleDeck(deck:[Card]) {
		self.deck = deck
	}

	func handleInWaitingRoom(data:[String:Any]) {
		let event = data["event"] as! Int
		if event == Event.Peers.rawValue {
			let ids = data["ids"] as! [Int]
			let names = data["names"] as! [String]
			peers.removeAll()
			for i in 0..<ids.count {
				peers.append((ids[i], names[i]))
			}
			self.delegateWatingRomm?.updatePeersList(peers)
		}
		if event == Event.Startgame.rawValue {
			delegateWatingRomm?.callGameView()
		}
		if event == Event.JoinGame.rawValue, let peer = data["data"] as? Int {
			self.scoreBoard.playerIsJoining(serviceId: peer)
			self.checkStartGame()
		}
		if event == Event.Card.rawValue {
			let card = data["data"] as! Int
			delegate?.updatePlayerCard(deck[card], false)
			currentPlayerCard = card
		}
		if event == Event.Deck.rawValue {
			let card = data["data"] as! Int
			delegate?.updateDeck(deck[card])
			currentDeckCard = card
		}
		if event == Event.PlayerId.rawValue, let id = data["data"] as? Int {
			self.myGameId = id
		}
	}
	
	func handleGameData(data: Any) {

		if let data = data as? [String:Int] {
			let event = data["event"]!
			
			if event == Event.Card.rawValue {
				let card = data["data"]!
				delegate?.updatePlayerCard(deck[card], false)
                currentPlayerCard = card
			}
			if event == Event.Deck.rawValue {
				let card = data["data"]!
				delegate?.updateDeck(deck[card])
                currentDeckCard = card
			}
		}
    }
	
	func receivee(_ data: Data) {
		let event = Int(data[0])
		switch event {
		case Event.Click.rawValue:
			let playerDeckCard = data[1]
			let id = data[2]
			let player = self.scoreBoard.players.filter({ (player) -> Bool in
				player.id == id
			})
			if currentDeckCard == playerDeckCard {
				runDeck(players: [player.first!])
			}
		case Event.Cards.rawValue:
			DispatchQueue.main.async {
				let deckCard = Int(data[1])
				self.previousDeckCard = self.currentDeckCard
				self.currentDeckCard = deckCard
				self.delegate?.updateDeck(self.deck[deckCard])
				let deckCount = Int(data[2])
				self.delegate?.updateDeckCount(deckCount)
				self.readPlayerData(data)
				self.readRank(data)
			}
		case Event.Ready.rawValue:
			self.shouldStartCountdown()
		case Event.Seconds.rawValue:
			let second = Int(data[1])
			self.delegate?.updateCounter(second)
		case Event.GameOver.rawValue:
			DispatchQueue.main.async {
				
				var players = [(Int,String,Int)]()
				let initIterator = 1
				let interval = 2
				for tick in stride(from: initIterator, to: data.count, by: interval) {
					let id = Int(data[tick])
					var name = "-"
					if id == self.myGameId {
						name = "You"
					} else {
						name = self.peers.filter({ (peer) -> Bool in peer.0 == id }).first!.1
					}
					let count = Int(data[tick + 1])
					let player = (id, name, count)
					players.append(player)
				}
				
				let rank = players.sorted(by: { (player1, player2) -> Bool in
					player1.2 >= player2.2
				})
				
				let winnerName = rank[0].1
				let winnerCount = rank[0].2
				
				var myPosition = 1
				for player in rank {
					if player.0 == self.myGameId {break}
					myPosition += 1
				}
				
				var stringPos = "-"
				switch myPosition {
				case 1: stringPos = "1st"
				case 2: stringPos = "2nd"
				case 3: stringPos = "3rd"
				case 4: stringPos = "4th"
				case 5: stringPos = "5th"
				case 6: stringPos = "6th"
				case 7: stringPos = "7th"
				case 8: stringPos = "8th"
				default: stringPos = "-"
				}
				
				let playerCount = rank[myPosition - 1].2
				
				self.delegate?.gameOver(winner: winnerName, winCount: winnerCount, playerPos: stringPos, playerCount: playerCount)
			}
		default:
			return
		}
	}
	
	func receive(_ data: Any) {
		
		if let data = data as? [String:Any] {
			self.handleInWaitingRoom(data: data)
			return
		}
		
		if let data = data as? [String:Int] {
			self.handleGameData(data: data)
			return
		}

		if let data = data as? [Card] {
			self.handleDeck(deck: data)
			return
		}
	}
    
    func startGame() {
        createDeck(order: 2)
		service.send(deck: deck)
		self.runDeck(players: self.scoreBoard.players)
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
			let card = Card(array: Array(tempSet).shuffled())
			deck.append(card)
		}
		
		for i in 0..<min_factor {
			for j in 0..<p {
				var tempCard = [Int]()
				for k in 0..<p { tempCard.append((k * p + (j + i * k) % p)) }
				tempCard.append(p * p + 1 + i)
				var tempSet = Set<Int>()
				for item in tempCard { tempSet.insert(item) }
				let card = Card(array: Array(tempSet).shuffled())
				deck.append(card)
			}
		}
		
		var tempCard = [Int]()
		for i in 0..<(min_factor + 1) { tempCard.append((p * p + i)) }
		var tempSet = Set<Int>()
		for item in tempCard { tempSet.insert(item) }
		let card = Card(array: Array(tempSet).shuffled())
		deck.append(card)
		self.deck = deck.shuffled()
	}
}

extension MutableCollection {
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
	func shuffled() -> [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}
