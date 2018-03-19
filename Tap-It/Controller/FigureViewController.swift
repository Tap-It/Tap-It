import UIKit

class FigureViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var layouted = false
	var bottomCard:UIImageView!
	var topCard:UIImageView!
	var stackView:UIStackView!
	var cardCover:UIImageView!
    var topScore = [PlayerScore]()
    var deckLabel = UILabel()
    var playerCardLabel = UILabel()

    var gameManager:FigureGameManager?
	let imageSizeRatio = CGFloat(65.0 / 300.0)
	var imageSize:CGSize!
	var hasLayout = false
	var numOfPeers: Int!
	var card:Card? {
		didSet {
			if self.hasLayout {
				self.setupCard(self.card!, isDeck: false)
			}
		}
	}
	var deckCard:Card? {
		didSet {
			if self.hasLayout {
				self.setupCard(self.deckCard!, isDeck: true)
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
        let gradientLayer = CAGradientLayer()
        let topColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.frame = view.frame
        view.layer.insertSublayer(gradientLayer, at: 0)
		
        gameManager!.delegate = self
		gameManager!.shouldStartGame()
    }
	
	override func viewDidLayoutSubviews() {
        
        loadLayout()
        
		if self.card != nil && self.hasLayout == false {
			self.setupCard(card!, isDeck: false)
		}
		if self.deckCard != nil && self.hasLayout == false {
			self.setupCard(deckCard!, isDeck: true)
		}
		self.hasLayout = true
	}
	
	private func setupCard(_ card: Card, isDeck: Bool) {
		if !isDeck {
            bottomCard.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })

            let frame = self.bottomCard.frame
			self.imageSize = CGSize(width: frame.width * self.imageSizeRatio, height: frame.height * self.imageSizeRatio)
			let centerPoint = CGPoint(x: frame.width / CGFloat(2), y: frame.height / CGFloat(2))
			let images = self.getImages(center: centerPoint, card: card, containerWidth: frame.width)
			for image in images {
				self.bottomCard.addSubview(image)
			}
		} else {
            topCard.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })

            let frame = self.topCard.frame
			self.imageSize = CGSize(width: frame.width * self.imageSizeRatio, height: frame.height * self.imageSizeRatio)
			let centerPoint = CGPoint(x: frame.width / CGFloat(2), y: frame.height / CGFloat(2))
			let images = self.getImages(center: centerPoint, card: card, containerWidth: frame.width)
			for image in images {
				self.topCard.addSubview(image)
			}
		}
	}
	
	private func getImages(center:CGPoint, card: Card, containerWidth: CGFloat) -> [UIImageView] {
		var images = [UIImageView]()
		var counter = 0
		let image_1 = self.getImage(center: center, number: card.face[counter].imageNumber, rotation: card.face[counter].rotation)
		images.append(image_1)
		counter += 1
		let distFromMax = CGFloat(1)
		var rad = CGFloat(card.rotation)
		let radAdder = (2 * CGFloat.pi) / CGFloat(card.face.count - 1)
		let maxLenght = (containerWidth / 2) - (imageSize.width / 1.3)
		while (card.face.count > counter) {
			let x = center.x + (maxLenght * distFromMax) * cos(rad)
			let y = center.y + (maxLenght * distFromMax) * sin(rad)
			let point = CGPoint(x: x, y: y)
			let image = self.getImage(center: point, number: card.face[counter].imageNumber, rotation: card.face[counter].rotation)
			images.append(image)
			counter += 1
			rad += radAdder
		}
		return images
	}
	
	private func getImage(center:CGPoint, number:Int, rotation:CGFloat) -> UIImageView {
		let imageOrigin = CGPoint(x: center.x - (imageSize.width / 2), y: center.y - (imageSize.height / 2))
		let imageRect = CGRect(origin: imageOrigin, size: imageSize)
		let image = UIImageView(frame: imageRect)
		let name = "figure_\(number)"
		image.image = UIImage(named: name)
        image.restorationIdentifier = "\(number)"
		image.contentMode = .scaleAspectFit
		image.transform = CGAffineTransform(rotationAngle: rotation)
        image.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(figureTapped(_:)))
        tap.delegate = self
        image.addGestureRecognizer(tap)

        return image
	}
    
    @objc func figureTapped(_ sender: UITapGestureRecognizer) {
        let view = sender.view as! UIImageView
        guard let imageNumber = view.restorationIdentifier else {
            return
        }
        self.gameManager?.checkAnswer(Int(imageNumber)!)
    }
}

extension FigureViewController {
    private func loadLayout() {
        if !layouted {
            let frame = view.safeAreaLayoutGuide.layoutFrame
            let safeTop = view.safeAreaInsets.top
            
            // BOTTOM CARD - PLAYER
			
			bottomCard = UIImageView()
            bottomCard.image = UIImage(named: "card_1")
            
            var tempHeight = CGFloat(0.0)
            var tempWidth = CGFloat(0.0)
            
            tempHeight = frame.height * 0.47
            tempWidth = tempHeight
            
            bottomCard.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: frame.height+safeTop-tempHeight-8, width: tempWidth, height: tempHeight)
            
            view.addSubview(bottomCard)
            
            // TOP CARD - DECK
			
			topCard = UIImageView()
            topCard.image = UIImage(named: "card_3")
            
            tempHeight = frame.height * 0.37
            tempWidth = tempHeight
            
            topCard.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: bottomCard.frame.minY-tempHeight-8, width: tempWidth, height: tempHeight)
            
            view.addSubview(topCard)
            
            // STACK VIEW - SCORE
			
			stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            
            tempHeight = topCard.frame.minY-safeTop-16
            tempWidth = frame.width-32
            
            stackView.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: safeTop+8, width: tempWidth, height: tempHeight)
            
            view.addSubview(stackView)
            

            // LEFT ARROW
            
            tempHeight = tempHeight * 0.7
            tempWidth = tempHeight/1.73

            let arrowUp = UIImageView(image: UIImage(named: "arrow_up"))
            arrowUp.contentMode = .scaleAspectFit
            arrowUp.frame = CGRect(x: bottomCard.frame.minX, y: topCard.frame.maxY-(topCard.frame.maxY*0.25), width: tempWidth, height: tempHeight)
            view.addSubview(arrowUp)
            
            
            deckLabel.frame = CGRect(x: arrowUp.frame.midX-10, y: arrowUp.frame.maxY+4, width: tempWidth*0.87, height: tempWidth*0.73)
            deckLabel.font = UIFont(name: "Futura", size: 50)
            deckLabel.adjustsFontSizeToFitWidth = true
            deckLabel.minimumScaleFactor = 0.1
            deckLabel.numberOfLines = 0
            deckLabel.text = String("20")

            view.addSubview(deckLabel)

            // RIGHT ARROW
            
            let arrowDown = UIImageView(image: UIImage(named: "arrow_down"))
            arrowDown.contentMode = .scaleAspectFit
            arrowDown.frame = CGRect(x: bottomCard.frame.maxX-tempWidth, y: bottomCard.frame.minY, width: tempWidth, height: tempHeight)
            view.addSubview(arrowDown)

            playerCardLabel.font = UIFont(name: "Futura", size: 50)
            playerCardLabel.adjustsFontSizeToFitWidth = true
            playerCardLabel.minimumScaleFactor = 0.1
            playerCardLabel.numberOfLines = 0
            playerCardLabel.text = String("20")

            playerCardLabel.frame = CGRect(x: arrowDown.frame.midX-16, y: arrowDown.frame.minY-(tempWidth*0.73)-4, width: tempWidth*0.87, height: tempWidth*0.73)
            view.addSubview(playerCardLabel)

            var countTopPlayers = 0
            while countTopPlayers < 3 {
                if numOfPeers > countTopPlayers {
                    if let objects = Bundle.main.loadNibNamed("PlayerScore", owner: self, options: nil), let scoreview = objects.first as? PlayerScore {
                        self.topScore.append(scoreview)
                        stackView.addArrangedSubview(scoreview)
                    }
                }
                countTopPlayers += 1
            }
			
			cardCover = UIImageView()
			cardCover.image = UIImage(named: "card_1")
			cardCover.frame.size = topCard.frame.size
			cardCover.frame.origin = CGPoint(x: topCard.frame.origin.x, y: topCard.frame.origin.y)
			let labelSize = CGSize(width: 30.0, height: 30.0)
			let labelOrigin = CGPoint(x: (cardCover.frame.width / 2) - (labelSize.width / 2), y: (cardCover.frame.height / 2) - (labelSize.height / 2))
			let counterLabel = UILabel(frame: CGRect(origin: labelOrigin, size: labelSize))
			let customFont = UIFont(name: "American Typewriter", size: 25.0)
//			counterLabel.text = String(second)
			counterLabel.font = customFont
			counterLabel.textColor = .black
			counterLabel.numberOfLines = 1
			counterLabel.textAlignment = .center
			cardCover.addSubview(counterLabel)
			view.addSubview(cardCover)
			
            layouted = true
			self.gameManager?.informReady()
        }
    }
}

extension FigureViewController : FigureProtocol {
	
	func updateCounter(_ second: Int) {
		DispatchQueue.main.async {
//			let labelSize = CGSize(width: 30.0, height: 30.0)
			let label = self.cardCover.subviews.first! as! UILabel
			label.text = String(second)
			UIView.transition(with: self.cardCover, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
//			let labelOrigin = CGPoint(x: (self.cardCover.frame.width / 2) - (labelSize.width / 2), y: (self.cardCover.frame.height / 2) - (labelSize.height / 2))
//			let counterLabel = UILabel(frame: CGRect(origin: labelOrigin, size: labelSize))
//			let customFont = UIFont(name: "American Typewriter", size: 25.0)
//			counterLabel.text = String(second)
//			counterLabel.font = customFont
//			counterLabel.textColor = .black
//			counterLabel.numberOfLines = 1
		}
	}
	
	func updateDeckCount(_ total: Int) {
		DispatchQueue.main.async {
//            self.deckLabel.text = String(total)
		}
	}
	
	func updatePlayerScore(_ score: Int) {
		DispatchQueue.main.async {
//            self.playerCardLabel.text = String(score)
		}
	}
	
	
	func updateTopScore(_ rank: [(String, Int)]) {
		DispatchQueue.main.async {
			for i in 0..<self.topScore.count {
				self.topScore[i].playerName.text = rank[i].0
				self.topScore[i].playerScore.text = String(rank[i].1)
			}
		}
	}
	
	func updatePlayerCard(_ card: Card) {
		DispatchQueue.main.async {
			self.card = card
		}
	}
	
    func updateDeck(_ card: Card) {
        DispatchQueue.main.async {
			self.deckCard = card
        }
    }
}
