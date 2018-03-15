import UIKit

class FigureViewController: UIViewController {
    
//    let gameManager = FigureGameManager()
	var gameManager:FigureGameManager?
//	let gameManager = FigureGameManager(playerName: "test")
	var topCard: UIImageView!
	var bottomCard: UIImageView!
    var first: PlayerScore!
    var second: PlayerScore!
    var third: PlayerScore!

    override func viewDidLoad() {
        super.viewDidLoad()

        // BACKGROUND GRADIENT
        
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // BOTTOM CARD
        
        bottomCard = UIImageView()
        bottomCard.image = UIImage(named: "card_3")
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomCard)
        
        bottomCard.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 8).isActive = true
        bottomCard.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -8).isActive = true
        bottomCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        bottomCard.widthAnchor.constraint(equalTo: bottomCard.heightAnchor, constant: 0).isActive = true
        bottomCard.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        
        // BOTTOM CARD
        
        topCard = UIImageView()
        topCard.image = UIImage(named: "card_3")
        topCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topCard)
        topCard.centerXAnchor.constraint(equalTo: bottomCard.centerXAnchor, constant: 0).isActive = true
        topCard.widthAnchor.constraint(equalTo: bottomCard.widthAnchor, multiplier: 0.8).isActive = true
        topCard.heightAnchor.constraint(equalTo: bottomCard.heightAnchor, multiplier: 0.8).isActive = true
        topCard.bottomAnchor.constraint(equalTo: bottomCard.topAnchor, constant: -16).isActive = true
        //topCard.
        
        if let objects = Bundle.main.loadNibNamed("PlayerScore", owner: self, options: nil), let scoreview = objects.first as? PlayerScore {
            first = scoreview
        }
        
        if let objects = Bundle.main.loadNibNamed("PlayerScore", owner: self, options: nil), let scoreview = objects.first as? PlayerScore {
            second = scoreview
        }
        
        if let objects = Bundle.main.loadNibNamed("PlayerScore", owner: self, options: nil), let scoreview = objects.first as? PlayerScore {
            third = scoreview
        }
        
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .equalSpacing
        //        stackview.spacing = 50.0
        stackview.addArrangedSubview(first)
        stackview.addArrangedSubview(second)
        stackview.addArrangedSubview(third)
        
        stackview.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackview)
        
        stackview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        stackview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        stackview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        stackview.bottomAnchor.constraint(equalTo: topCard.topAnchor, constant: -8).isActive = true
        stackview.heightAnchor.constraint(equalTo: bottomCard.heightAnchor, multiplier: 0.20).isActive = true
        
        
        
        
        
        
        gameManager!.delegate = self
		gameManager!.shouldStartGame()
    }
	
}

extension FigureViewController : FigureProtocol {
	
	func updatePlayerCard(_ card: Card) {
		DispatchQueue.main.async {
//			self.cardView.setupFigures(figures: card.face)
		}
	}
	
    func updateDeck(_ card: Card) {
        DispatchQueue.main.async {
//			self.deckView.setupFigures(figures: card.face)
        }
    }
}

extension FigureViewController : CardViewProtocol {
    func getTapped(figureNumber: Int) {
        gameManager?.checkAnswer(figureNumber)
    }
}
