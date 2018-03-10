import UIKit

class Figure: NSObject, NSCoding {
    
    let imageNumber: Int
    
    enum FigureKeys:String {
        case imageNumber = "imageNumber"
    }
    
    init(imageNumber: Int) {
        self.imageNumber = imageNumber
    }
    
    func loadImage() -> UIImage {
        return UIImage(named: "figure_\(imageNumber)")!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imageNumber, forKey: FigureKeys.imageNumber.rawValue)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeInteger(forKey: FigureKeys.imageNumber.rawValue)
        self.init(imageNumber: number)
    }
}



class Card: NSObject, NSCoding {
    
    let face: [Figure]

    enum CardKeys:String {
        case face = "face"
    }

    init(array: [Int]) {
        var tempFace = [Figure]()
        for i in array {
            let figure = Figure(imageNumber: i)
            tempFace.append(figure)
        }
        self.face = tempFace
    }

    init(face: [Figure]) {
        self.face = face
    }

    
    func encode(with aCoder: NSCoder) {
//        let intArr = face.map { (face) -> Int in
//            face.imageNumber
//        }
        aCoder.encode(face, forKey: CardKeys.face.rawValue)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let restored = aDecoder.decodeObject(forKey: CardKeys.face.rawValue) as? [Figure]
        self.init(face: restored!)
    }

}
