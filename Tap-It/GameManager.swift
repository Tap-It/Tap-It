import Foundation

protocol GameManagerProtocol {
    func updateWinner(dataString: String)
    func updateQuestion(question: String)
}

protocol ServiceProtocol {
    func send(_ data: [String:String])
    func setDelegate(_ gameManager: GameManager)
}

enum Event: String {
    case Click = "Click",
    Update = "Update"
}

class GameManager {
    
    
    var question: String!
    var delegate: GameManagerProtocol?
    let service: ServiceProtocol
    
    init() {
        self.service = GameService()
        self.service.setDelegate(self)
    }
    
    func checkAnswer(_ answer: String) {
        if answer == question {
            // get my name from the gameservice
            let name = "nameFromGameService"
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
}

extension GameManager: GameServiceDelegate {
    func receive(_ data: [String : String]) {
        if data["event"] == Event.Click.rawValue {
            if let winner = data["data"] {
                delegate?.updateWinner(dataString: winner)
                service.send(generateRandomQuestion())
            }
        }
        if data["event"] == Event.Update.rawValue {
            if let question = data["data"] {
                delegate?.updateQuestion(question: question)
            }
        }
    }
    
    func startGame() {
        service.send(generateRandomQuestion())
    }
}





