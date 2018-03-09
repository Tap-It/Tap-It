import Foundation

protocol GameManagerProtocol {
	func updateScoreboard(scoreboard: [String])
    func updateQuestion(question: String)
}

protocol ServiceProtocol {
    func send(_ data: [String:String])
    func setDelegate(_ gameManager: GameManager)
    func getName() -> String
}

enum Event: String {
    case Click = "Click",
    Update = "Update",
	Score = "Score"
}

class GameManager {
    
    var question: String!
    var delegate: GameManagerProtocol?
    let service: ServiceProtocol
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
        self.service = GameService()
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

extension GameManager: GameServiceDelegate {
	
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
	
    func receive(_ data: [String : String]) {
		let event = data["event"]!
		switch event {
		case Event.Click.rawValue:
			if let winner = data["data"] {
				self.updateScore(winner: winner)
				service.send(generateRandomQuestion())
			}
		case Event.Update.rawValue:
			if let question = data["data"] {
				DispatchQueue.main.async {
					self.delegate?.updateQuestion(question: question)
					self.question = question
				}
			}
		case Event.Score.rawValue:
			var scoreDisplay = [String]()
			for (player, score) in data {
				if player == "event" {continue}
				scoreDisplay.append(score)
			}
			if scoreDisplay.count > 0 {
				DispatchQueue.main.async {
					self.delegate?.updateScoreboard(scoreboard: scoreDisplay)
				}
			}
		default:
			return
		}
    }
    
    func startGame() {
        service.send(generateRandomQuestion())
    }
}





