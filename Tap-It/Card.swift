import UIKit

struct Figure {
    let imageNumber: Int
    
    func loadImage() -> UIImage {
        return UIImage(named: "figure_\(imageNumber)")!
    }
}

struct Card {
    
    let face: [Figure] // objects
    let id = 0
    
    init(size: Int) {
        var array = [Figure]()
        for i in 1...size {
            array.append(Figure(imageNumber: i))
            }
        self.face = array
    }
    
    init(array: [Int]) {
        var tempFace = [Figure]()
        for i in array {
            let figure = Figure(imageNumber: i)
            tempFace.append(figure)
        }
        
        self.face = tempFace
    }
    
    
}
