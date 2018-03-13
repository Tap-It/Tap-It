import UIKit

protocol CardViewProtocol {
    func getTapped(figureNumber: Int)
}

class CardView: UIView {
    
    var delegate: CardViewProtocol?

	@IBOutlet weak var figure0: UIImageView!
	@IBOutlet weak var figure1: UIImageView!
	@IBOutlet weak var figure2: UIImageView!
	@IBOutlet weak var figure3: UIImageView!
	@IBOutlet weak var figure4: UIImageView!
	@IBOutlet weak var figure5: UIImageView!
	@IBOutlet weak var figure6: UIImageView!
	@IBOutlet weak var figure7: UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
    
	
	@IBAction func tapped(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! UIImageView
        guard let imageNumber = view.restorationIdentifier else {
            return
        }
        self.delegate?.getTapped(figureNumber: Int(imageNumber)!)
	}

    func setupFigures(figures: [Figure]) {
		self.figure0.image = figures[0].loadImage()
		self.figure1.image = figures[1].loadImage()
		self.figure2.image = figures[2].loadImage()
		self.figure3.image = figures[3].loadImage()
		self.figure4.image = figures[4].loadImage()
		self.figure5.image = figures[5].loadImage()
		self.figure6.image = figures[6].loadImage()
		self.figure7.image = figures[7].loadImage()

        self.figure0.restorationIdentifier = String(figures[0].imageNumber)
        self.figure1.restorationIdentifier = String(figures[1].imageNumber)
        self.figure2.restorationIdentifier = String(figures[2].imageNumber)
        self.figure3.restorationIdentifier = String(figures[3].imageNumber)
        self.figure4.restorationIdentifier = String(figures[4].imageNumber)
        self.figure5.restorationIdentifier = String(figures[5].imageNumber)
        self.figure6.restorationIdentifier = String(figures[6].imageNumber)
        self.figure7.restorationIdentifier = String(figures[7].imageNumber)

    }
}
