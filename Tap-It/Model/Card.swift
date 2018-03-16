import UIKit

class Figure: NSObject, NSCoding {
    
    let imageNumber: Int
	let rotation: CGFloat
    
    enum FigureKeys:String {
        case imageNumber = "imageNumber",
        rotation = "rotation"
    }
    
	init(imageNumber: Int, rotation:CGFloat) {
        self.imageNumber = imageNumber
		self.rotation = rotation
    }
    
    func loadImage() -> UIImage {
        return UIImage(named: "figure_\(imageNumber)")!
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imageNumber, forKey: FigureKeys.imageNumber.rawValue)
        aCoder.encode(rotation, forKey: FigureKeys.rotation.rawValue)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let number = aDecoder.decodeInteger(forKey: FigureKeys.imageNumber.rawValue)
		let rotation = aDecoder.decodeFloat(forKey: FigureKeys.rotation.rawValue)
		self.init(imageNumber: number, rotation: CGFloat(rotation))
    }
}



class Card: NSObject, NSCoding {
    
    let face: [Figure]
	let rotation: CGFloat

    enum CardKeys:String {
        case face = "face",
		rotation = "rotation"
    }

    init(array: [Int]) {
        var tempFace = [Figure]()
        for i in array {
			let rotation = Card.randomAngle()
			let figure = Figure(imageNumber: i, rotation: rotation)
            tempFace.append(figure)
        }
        self.face = tempFace
		self.rotation = Card.randomAngle()
    }

	init(face: [Figure], rotation:CGFloat) {
        self.face = face
		self.rotation = rotation
    }
	
	class func randomAngle() -> CGFloat {
		let random = CGFloat(arc4random_uniform(200)) / CGFloat(100)
		return random * CGFloat.pi
	}

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(face, forKey: CardKeys.face.rawValue)
		aCoder.encode(rotation, forKey: CardKeys.rotation.rawValue)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        let restored = aDecoder.decodeObject(forKey: CardKeys.face.rawValue) as? [Figure]
		let rotation = aDecoder.decodeFloat(forKey: CardKeys.rotation.rawValue)
		self.init(face: restored!, rotation: CGFloat(rotation))
    }

}
