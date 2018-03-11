import Foundation

protocol FigureProtocol {
    func updateDeck(_ card: Card)
    func updatePlayerCard(_ card: Card)
}

protocol FigureServiceProtocol {
    func send(_ data: [String:String])
    func send(deck: [Card])
    func setDelegate(_ gameManager: FigureGameManager)
    func getName() -> String
}


class FigureGameManager {
    
    var deck = [Card]()
    var question: String!
    var delegate: FigureProtocol?
    let service: FigureServiceProtocol
    var scoreBoard = [String:Int]() {
        didSet {
            var data = [String:String]()
            data["event"] = Event.Score.rawValue
            for (player, score) in scoreBoard {
                let bundleScore = "\(player): \(score)"
                data[player] = bundleScore
            }
            service.send(data)
        }
    }
    var backupScore = [String:Int]()
    
    init() {
        self.service = FigureGameService()
        self.service.setDelegate(self)
        self.addPlayer(player: service.getName())
    }
    
    func checkAnswer(_ answer: String) {
        if answer == question {
            // get my name from the gameservice
            let name = service.getName()
            var data = [String:String]()
            data["event"] = Event.Click.rawValue
            data["data"] = name
            service.send(data)
        } else {
            print("wrong. blocked!")
        }
    }
    
    private func generateRandomQuestion() -> [String:String] {
        let random = arc4random_uniform(8)+1
        var data = [String:String]()
        data["event"] = Event.Update.rawValue
        data["data"] = String(random)
        return data
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
        if self.scoreBoard.keys.contains(winner) {
            self.scoreBoard[winner] = self.scoreBoard[winner]! + 1
        }
    }
}

extension FigureGameManager: FigureGameServiceDelegate {
    
    func addPlayer(player: String) {
        if !self.scoreBoard.keys.contains(player) {
            self.scoreBoard[player] = self.backupScore.keys.contains(player) ? self.backupScore[player]! : 0
        }
    }
    
    func removePlayer(player: String) {
        if self.scoreBoard.keys.contains(player) {
            if self.scoreBoard[player]! > 0 {
                self.backupScore[player] = self.scoreBoard[player]!
            }
            self.scoreBoard.removeValue(forKey: player)
        }
    }
    
    func receive(_ data: Any) {
//        let event = data["event"]!
//        switch event {
//        case Event.Click.rawValue:
//            if let winner = data["data"] {
//                self.updateScore(winner: winner)
//                service.send(generateRandomQuestion())
//            }
//        case Event.Update.rawValue:
//            if let question = data["data"] {
//                DispatchQueue.main.async {
////                    self.delegate?.updateQuestion(question: question)
//                    self.question = question
//                }
//            }
//        case Event.Score.rawValue:
//            var scoreDisplay = [String]()
//            for (player, score) in data {
//                if player == "event" {continue}
//                scoreDisplay.append(score)
//            }
//            if scoreDisplay.count > 0 {
//                DispatchQueue.main.async {
////                    self.delegate?.updateScoreboard(scoreboard: scoreDisplay)
//                }
//            }
//        default:
//            return
//        }
        
        
        if let data = data as? [Card] {
            deck = data
        }
    }
    
    func startGame() {
        createDeck(order: 7)
        service.send(generateRandomQuestion())
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

		delegate?.updateDeck(deck[0])
		delegate?.updatePlayerCard(deck[1])
		service.send(deck: deck)
	}
}






