import Foundation

protocol GameManagerProtocol {
    func addData(dataString: String)
    func updateData(dataString: String)
    func updateRandom(dataString: String)
}

class GameManager {
    
    enum Event: String {
        case Click = "Click",
        Random = "Random",
        Update = "Update"
    }
    
    var question: String!
    var delegate: GameManagerProtocol?
    
    func checkAnswer(_ answer: String) {
        if answer == question {
            // get my name from the gameservice
            let name = "nameFromGameService"
            var data = [String:String]()
            data["event"] = Event.Click.rawValue
            data["data"] = name
//            service.send(data)
        } else {
            print("wrong. blocked!")
        }
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
