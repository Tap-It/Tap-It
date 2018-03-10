import Foundation

protocol FigureProtocol {
    func updateDeck(_ card: Card)
}

protocol FigureServiceProtocol {
    func send(_ data: [String:String])
    func send(deck: [Card])
    func setDelegate(_ gameManager: FigureGameManager)
    func getName() -> String
}


class FigureGameManager {
    
    var deck = [Card]() {
        didSet {
            delegate?.updateDeck(deck[0])
        }
    }
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
        generateDeck()
        service.send(generateRandomQuestion())
    }
}


extension FigureGameManager {
    func generateDeck() {
        
        let tempArray = [
            [0, 1, 2, 3, 4, 5, 6, 49],
            [7, 8, 9, 10, 11, 12, 13, 49],
            [49, 14, 15, 16, 17, 18, 19, 20],
            [49, 21, 22, 23, 24, 25, 26, 27],
            [32, 33, 34, 49, 28, 29, 30, 31],
            [35, 36, 37, 38, 39, 40, 41, 49],
            [42, 43, 44, 45, 46, 47, 48, 49],
            [0, 35, 7, 42, 14, 50, 21, 28],
            [1, 36, 8, 43, 15, 50, 22, 29],
            [2, 37, 9, 44, 16, 50, 23, 30],
            [3, 38, 10, 45, 17, 50, 24, 31],
            [32, 4, 39, 11, 50, 46, 18, 25],
            [33, 5, 40, 12, 47, 50, 19, 26],
            [34, 6, 41, 13, 48, 50, 20, 27],
            [0, 32, 48, 8, 16, 40, 51, 24],
            [1, 33, 41, 42, 17, 51, 9, 25],
            [34, 35, 10, 43, 2, 18, 51, 26],
            [51, 3, 36, 11, 44, 19, 27, 28],
            [4, 37, 12, 45, 51, 20, 21, 29],
            [5, 38, 13, 14, 51, 46, 22, 30],
            [6, 39, 7, 15, 51, 23, 47, 31],
            [0, 38, 9, 47, 18, 52, 27, 29],
            [1, 39, 10, 48, 19, 52, 21, 30],
            [2, 40, 42, 11, 20, 22, 52, 31],
            [32, 3, 41, 43, 12, 14, 52, 23],
            [33, 35, 4, 44, 13, 15, 52, 24],
            [34, 36, 5, 7, 45, 16, 52, 25],
            [37, 6, 8, 46, 17, 52, 26, 28],
            [0, 33, 36, 10, 46, 20, 53, 23],
            [1, 34, 37, 11, 14, 47, 53, 24],
            [2, 38, 12, 15, 48, 53, 25, 28],
            [3, 39, 42, 13, 16, 53, 26, 29],
            [4, 7, 40, 43, 17, 53, 27, 30],
            [5, 8, 41, 44, 18, 21, 53, 31],
            [32, 35, 6, 9, 45, 19, 53, 22],
            [0, 41, 11, 45, 15, 54, 26, 30],
            [1, 35, 12, 46, 16, 54, 27, 31],
            [32, 2, 36, 13, 47, 17, 21, 54],
            [33, 3, 37, 7, 48, 18, 22, 54],
            [34, 4, 38, 8, 42, 19, 54, 23],
            [5, 39, 9, 43, 20, 54, 24, 28],
            [6, 40, 10, 44, 14, 54, 25, 29],
            [0, 34, 39, 44, 12, 17, 22, 55],
            [1, 40, 55, 13, 45, 18, 23, 28],
            [2, 7, 41, 46, 19, 55, 24, 29],
            [3, 8, 47, 35, 20, 55, 25, 30],
            [4, 9, 14, 48, 55, 36, 26, 31],
            [32, 37, 10, 15, 55, 27, 42, 5],
            [33, 43, 38, 6, 11, 16, 21, 55],
            [0, 37, 43, 13, 19, 56, 25, 31],
            [32, 1, 38, 7, 44, 20, 56, 26],
            [33, 2, 39, 8, 45, 14, 56, 27],
            [34, 3, 40, 9, 46, 15, 21, 56],
            [4, 41, 10, 47, 16, 22, 56, 28],
            [35, 5, 11, 48, 17, 23, 56, 29],
            [36, 6, 42, 12, 56, 18, 24, 30],
            [49, 50, 51, 52, 53, 54, 55, 56]
        ]
        
        for i in tempArray {
            let card = Card(array: i)
            deck.append(card)
        }
        
        
        service.send(deck: deck)
    }
}






