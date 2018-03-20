import UIKit
import AudioToolbox

class FigureViewController: UIViewController {
	
	var layouted = false
	var firstShow = true
    var timerBlock = Timer()
    
	var bottomCard: UIImageView!
	var topCard: UIImageView!
    var copyBottomCard: UIImageView!
    var copyTopCard: UIImageView!
	var stackView: UIStackView!
	var cardCover: UIImageView!
	var roundedView:UIView!
	var counterView:UIView!
	var topScore = [PlayerScore]()
	var deckLabel: UILabel!
	var playerCardLabel: UILabel!
	
	var gameManager:FigureGameManager?
	let imageSizeRatio = CGFloat(65.0 / 300.0)
	var imageSize:CGSize!
	var numOfPeers: Int!
	var card:Card?
	var deckCard:Card?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.layer.insertSublayer(self.getGradientBackground(), at: 0)
		
		deckLabel = UILabel()
		playerCardLabel = UILabel()
		
		stackView = UIStackView()
		
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
		
		gameManager!.delegate = self
		gameManager!.shouldStartGame()
	}
	
	private func getGradientBackground() -> CAGradientLayer {
		let gradientLayer = CAGradientLayer()
		let topColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
		let bottomColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
		gradientLayer.colors = [topColor, bottomColor]
		gradientLayer.frame = view.frame
		return gradientLayer
	}
	
	override func viewDidLayoutSubviews() {
		loadLayout()
	}
	
	private func setupCard(_ gotAnswer: Bool) {
		
		if firstShow {
			loadTopCard()
			loadBottomCard()
			firstShow = false
			return
		}
		print(gotAnswer, "EH EH EH EH EH EH", gotAnswer)
		
		self.gameManager?.canProcessCache = false
        blockClick()
		
		// COPY OF DECK CARD
		
		if topCard.subviews.count > 0 {
			copyTopCard = UIImageView()
			copyTopCard.frame = topCard.frame
			copyTopCard.image = topCard.image
			for image in topCard.subviews {
				let image = image as! UIImageView
				copyTopCard.addSubview(image)
			}
		}

        for view in copyTopCard.subviews {
            if let view = view as? UIImageView {
                view.layer.shadowColor = UIColor.green.cgColor
                view.layer.shadowOffset = CGSize(width: 0, height: 1)
                view.layer.shadowOpacity = 1
                view.layer.shadowRadius = 2.0
                view.clipsToBounds = false
            }
        }

		// UPDATE DECK CARD
		
		topCard.subviews.forEach({ (view) in
			view.removeFromSuperview()
		})
		
		self.loadTopCard()
		
		if gotAnswer {
            
            for view in bottomCard.subviews {
                if let view = view as? UIImageView {
                    view.layer.shadowColor = UIColor.green.cgColor
                    view.layer.shadowOffset = CGSize(width: 0, height: 1)
                    view.layer.shadowOpacity = 1
                    view.layer.shadowRadius = 2.0
                    view.clipsToBounds = false
                }
            }


            copyBottomCard = UIImageView()
            copyBottomCard.frame = bottomCard.frame
            copyBottomCard.image = bottomCard.image
            for image in bottomCard.subviews {
                let image = image as! UIImageView
                copyBottomCard.addSubview(image)
            }
            
            self.view.addSubview(copyBottomCard)
            self.view.addSubview(copyTopCard)

            
            self.bottomCard.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })

            self.loadBottomCard()

            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                self.copyTopCard.image = UIImage(named: "card_1")
                self.copyTopCard.frame = self.bottomCard.frame
                
                for image in self.copyTopCard.subviews {
                    let bottomImage = self.bottomCard.subviews.filter({ (bottom) -> Bool in
                        bottom.restorationIdentifier == image.restorationIdentifier
                    })
                    image.frame = bottomImage.first!.frame
                    image.bounds = bottomImage.first!.bounds
                }
            }, completion: { (_) in
                self.copyTopCard.removeFromSuperview()
                self.copyBottomCard.removeFromSuperview()
                self.unblockClick()
				self.gameManager?.canProcessCache = true
				self.gameManager?.processDataCache()
            })
        } else {
            self.view.addSubview(copyTopCard)
            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
				self.copyTopCard.frame.origin.x = self.view.frame.size.width + 50
			}, completion: { (_) in
				self.copyTopCard.removeFromSuperview()
                self.unblockClick()
				self.gameManager?.canProcessCache = true
				self.gameManager?.processDataCache()
			})
		}

	}
	
	private func loadTopCard() {
		let frame = self.topCard.frame
		self.imageSize = CGSize(width: frame.width * self.imageSizeRatio, height: frame.height * self.imageSizeRatio)
		let centerPoint = CGPoint(x: frame.width / CGFloat(2), y: frame.height / CGFloat(2))
		let images = self.getImages(center: centerPoint, card: deckCard!, containerWidth: frame.width)
		for image in images {
			self.topCard.addSubview(image)
		}
		
	}
	private func loadBottomCard() {
		let frame = self.bottomCard.frame
		self.imageSize = CGSize(width: frame.width * self.imageSizeRatio, height: frame.height * self.imageSizeRatio)
		let centerPoint = CGPoint(x: frame.width / CGFloat(2), y: frame.height / CGFloat(2))
		let images = self.getImages(center: centerPoint, card: self.card!, containerWidth: frame.width)
		for image in images {
			self.bottomCard.addSubview(image)
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
		image.addGestureRecognizer(tap)
		
		return image
	}
	
	@objc func figureTapped(_ sender: UITapGestureRecognizer) {
		// 1: independente do tipo de click, a view deveria perder o userinteraction pois espera por instrucoes do host ou errou
//		self.blockClick()
		let view = sender.view as! UIImageView
		guard let imageNumber = view.restorationIdentifier else {
			return
		}
		self.gameManager?.checkAnswer(Int(imageNumber)!)
	}
    
    private func blockClick() {
		// 12: tira a userinteraction das cartas de cima e de baixo
        topCard.isUserInteractionEnabled = false
        bottomCard.isUserInteractionEnabled = false
    }
    
    private func unblockClick() {
		// 13: coloca de volta a userinteraction nas cartas
        topCard.isUserInteractionEnabled = true
        bottomCard.isUserInteractionEnabled = true
		
		// 14: limpa o background das imagens
        for view in bottomCard.subviews {
            if let view = view as? UIImageView {
                view.layer.shadowColor = UIColor.clear.cgColor
            }
        }
		
		// 15: limpa o background das imagens
        for view in topCard.subviews {
            if let view = view as? UIImageView {
                view.layer.shadowColor = UIColor.clear.cgColor
            }
        }
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
			bottomCard.isUserInteractionEnabled = true
			
			var tempHeight = CGFloat(0.0)
			var tempWidth = CGFloat(0.0)
			
			tempHeight = frame.height * 0.47
			tempWidth = tempHeight
			
			bottomCard.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: frame.height+safeTop-tempHeight-8, width: tempWidth, height: tempHeight)
			
			view.addSubview(bottomCard)
			
			// TOP CARD - DECK
			
			topCard = UIImageView()
			topCard.image = UIImage(named: "card_3")
			topCard.isUserInteractionEnabled = true
			
			tempHeight = frame.height * 0.37
			tempWidth = tempHeight
			
			topCard.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: bottomCard.frame.minY-tempHeight-8, width: tempWidth, height: tempHeight)
			
			view.addSubview(topCard)
			
			// STACK VIEW - SCORE
			
			stackView.axis = .horizontal
			stackView.distribution = .equalSpacing
			
			tempHeight = topCard.frame.minY-safeTop-16
			tempWidth = frame.width-32
			
			stackView.frame = CGRect(x: (frame.width/2)-(tempWidth/2), y: safeTop+8, width: tempWidth, height: tempHeight)
			
			view.addSubview(stackView)
			
			
			// LEFT ARROW
			
			tempHeight = tempHeight * 0.7
			tempWidth = tempHeight/1.73
            print(tempWidth, "WI WI WI WI DTH!")
            //33.4 * x = 40

			let arrowUp = UIImageView(image: UIImage(named: "arrow_up"))
			arrowUp.contentMode = .scaleAspectFit
			arrowUp.frame = CGRect(x: bottomCard.frame.minX, y: topCard.frame.maxY-(tempWidth*2.65), width: tempWidth, height: tempHeight)
			view.addSubview(arrowUp)
			
			deckLabel.frame = CGRect(x: arrowUp.frame.midX-10, y: arrowUp.frame.maxY+4, width: tempWidth*1.21, height: tempWidth)
			deckLabel.font = UIFont(name: "Janda Safe and Sound Solid", size: 50)
			deckLabel.adjustsFontSizeToFitWidth = true
			deckLabel.minimumScaleFactor = 0.1
			deckLabel.numberOfLines = 0
			
			view.addSubview(deckLabel)
			
			// RIGHT ARROW
			
			let arrowDown = UIImageView(image: UIImage(named: "arrow_down"))
			arrowDown.contentMode = .scaleAspectFit
			arrowDown.frame = CGRect(x: bottomCard.frame.maxX-tempWidth, y: bottomCard.frame.minY, width: tempWidth, height: tempHeight)
			view.addSubview(arrowDown)
			
			playerCardLabel.font = UIFont(name: "Janda Safe and Sound Solid", size: 50)
			playerCardLabel.adjustsFontSizeToFitWidth = true
			playerCardLabel.minimumScaleFactor = 0.1
			playerCardLabel.numberOfLines = 0
			
			playerCardLabel.frame = CGRect(x: arrowDown.frame.midX-16, y: arrowDown.frame.minY-tempWidth-4, width: tempWidth*1.21, height: tempWidth)
			view.addSubview(playerCardLabel)
			
			// SET THE COUNTER VIEW
			
			counterView = UIView()
			counterView.frame = self.view.frame
			counterView.layer.insertSublayer(self.getGradientBackground(), at: 0)
			
			roundedView = UIView()
			roundedView.backgroundColor = UIColor(red: 243.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
			let roundedSize = CGSize(width: counterView.frame.width * 0.5, height: counterView.frame.width * 0.5)
			let roundedOrigin = CGPoint(x: (counterView.frame.width / 2) - (roundedSize.width / 2), y: (counterView.frame.height / 2) - (roundedSize.height / 2))
			let roundedFrame = CGRect(origin: roundedOrigin, size: roundedSize)
			roundedView.frame = roundedFrame
			roundedView.layer.cornerRadius = roundedSize.width / 2.0
			let labelSize = CGSize(width: 50.0, height: 50.0)
			let labelOrigin = CGPoint(x: (roundedView.frame.width / 2) - (labelSize.width / 2), y: (roundedView.frame.height / 2) - (labelSize.height / 2))
			let counterLabel = UILabel(frame: CGRect(origin: labelOrigin, size: labelSize))
			let customFont = UIFont(name: "Janda Safe and Sound Solid", size: 30.0)
			counterLabel.font = customFont
			counterLabel.textColor = .black
			counterLabel.numberOfLines = 1
			counterLabel.textAlignment = .center
			roundedView.addSubview(counterLabel)
			counterView.addSubview(roundedView)
			view.addSubview(counterView)
			
			layouted = true
			self.gameManager?.informReady()
		}
	}
}

extension FigureViewController : FigureProtocol {
	
	func gameOver(winner:String, winCount:Int, playerPos:String, playerCount:Int) {
		
		let overView = UIView()
		overView.frame = self.view.frame
		overView.layer.insertSublayer(self.getGradientBackground(), at: 0)

		let rankView = UIView()
		let rankSize = CGSize(width: self.view.frame.width * 0.9, height: self.view.frame.height * 0.9)
		let rankOrigin = CGPoint(x: (self.view.frame.width / 2.0) - (rankSize.width / 2.0), y: (self.view.frame.height / 2.0) - (rankSize.height / 2.0))
		rankView.frame = CGRect(origin: rankOrigin, size: rankSize)
		rankView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.4)
		rankView.layer.cornerRadius = rankView.frame.width / 13
		
		// WINNER VIEW
		let winnerView = UIView()
		let resultSize = CGSize(width: rankView.frame.width, height: (rankView.frame.height / 2))
		let resultOrigin = CGPoint(x: 0.0, y: 40.0)
		winnerView.frame = CGRect(origin: resultOrigin, size: resultSize)
		
		// CROWN
		let crown = UIImageView()
		let crownSize = CGSize(width: (winnerView.frame.width / 2), height: (winnerView.frame.width / 2))
		let crownOrigin = CGPoint(x: (winnerView.frame.width / 2.0) - (crownSize.width / 2), y: 10.0)
		crown.frame = CGRect(origin: crownOrigin, size: crownSize)
		crown.image = UIImage(named: "trophy")
		winnerView.addSubview(crown)
		
		// WINNER LABEL 1
		let resultLabel = UILabel()
		let labelSize = CGSize(width: winnerView.frame.width, height: 120.0)
		let labelOrigin   = CGPoint(x: (winnerView.frame.width / 2) - (labelSize.width / 2), y: (crown.frame.origin.y) + (crown.frame.size.height) + 10.0)
		resultLabel.frame = CGRect(origin: labelOrigin, size: labelSize)
		resultLabel.font = UIFont(name: "American Typewriter", size: 30.0)
		resultLabel.textColor = .black
		resultLabel.numberOfLines = 0
		resultLabel.lineBreakMode = .byWordWrapping
		resultLabel.textAlignment = .center
		
		resultLabel.text = "\(winner) won!\n(\(winCount) cards)"
		winnerView.addSubview(resultLabel)
		rankView.addSubview(winnerView)
		
		// PLAYER LABEL
		let playerLabel = UILabel()
		let playerSize = CGSize(width: rankView.frame.width, height: 120.0)
		let playerOrigin = CGPoint(x: (rankView.frame.width / 2) - (playerSize.width / 2), y: (winnerView.frame.origin.y) + (winnerView.frame.size.height) + 20.0)
		playerLabel.frame = CGRect(origin: playerOrigin, size: playerSize)
		playerLabel.font = UIFont(name: "American Typewriter", size: 30.0)
		playerLabel.numberOfLines = 0
		playerLabel.lineBreakMode = .byWordWrapping
		playerLabel.textColor = .black
		playerLabel.textAlignment = .center
		if winner == "You" {
			playerLabel.text = "Congratulations!"
		} else {
			playerLabel.text = "You finished \(playerPos)!\n(\(playerCount) cards)"
		}
		rankView.addSubview(playerLabel)
		
		// EXIT BUTTON
		let overButton = UIButton()
		let buttonSize = CGSize(width: rankView.frame.width, height: 80.0)
		let buttonOrigin = CGPoint(x: 0.0, y: rankView.frame.size.height - buttonSize.height)
		overButton.frame = CGRect(origin: buttonOrigin, size: buttonSize)
		overButton.setTitle("Exit", for: .normal)
		overButton.backgroundColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 0.4)
		overButton.titleLabel?.font = UIFont(name: "American Typewriter", size: 25.0)
		overButton.addTarget(self, action: #selector(handleGameOverButton), for: UIControlEvents.touchUpInside)
		overButton.setTitleColor(.white, for: .normal)
		rankView.addSubview(overButton)
		
		rankView.clipsToBounds = true
		overView.addSubview(rankView)
		self.view.addSubview(overView)
		
//		UIView.transition(with: rankView, duration: 0.5, options: .curveEaseIn, animations: {
//			rankView.frame.origin.y = self.view.frame.origin.y
//		}, completion: nil)
	}
	
	@objc func handleGameOverButton() {
		self.performSegue(withIdentifier: "gameover", sender: nil)
	}

	func updateCounter(_ second: Int) {
		DispatchQueue.main.async {
			let label = self.roundedView.subviews.first! as! UILabel
			if second == 0 {
				self.setupCard(false)
				//self.setupCard(self.card!, isDeck: false)
				UIView.transition(with: self.counterView, duration: 0.5, options: .curveEaseIn, animations: {
					self.counterView.frame.origin.y = self.view.frame.size.height + 50
				}, completion: { (_) in
					self.counterView.removeFromSuperview()
				})
				return
			}
			label.text = String(second)
			UIView.transition(with: self.roundedView, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
		}
	}
	
	func updateDeckCount(_ total: Int) {
		self.deckLabel.text = String(total)
	}
	
	func updatePlayerScore(_ score: Int) {
		self.playerCardLabel.text = String(score)
	}
	
	
	func updateTopScore(_ rank: [(String, Int)]) {
		for i in 0..<self.topScore.count {
			self.topScore[i].playerName.text = rank[i].0
			self.topScore[i].playerScore.text = String(rank[i].1)
		}
	}
	
	func updatePlayerCard(_ card: Card, _ gotAnswer: Bool) {
		self.card = card
		if timerBlock.isValid {
			timerBlock.invalidate()
		}
		if layouted {
			setupCard(gotAnswer)
		}
	}
	
	func updateDeck(_ card: Card) {
		self.deckCard = card
	}
    
    func blockPlayer() {
		// 7: bloqueia o click do jogador (ja nao poderiamos ter feito isso no inicio do tap gesture?)
        blockClick()

		// 8: pinta de vermelho as imagens da carta do jogador
        for view in bottomCard.subviews {
            if let view = view as? UIImageView {
                view.layer.shadowColor = UIColor.red.cgColor
                view.layer.shadowOffset = CGSize(width: 0, height: 1)
                view.layer.shadowOpacity = 1
                view.layer.shadowRadius = 2.0
                view.clipsToBounds = false
            }
        }

		// 9: pinta de vermelho as imagens do deck
        for view in topCard.subviews {
            if let view = view as? UIImageView {
                view.layer.shadowColor = UIColor.red.cgColor
                view.layer.shadowOffset = CGSize(width: 0, height: 1)
                view.layer.shadowOpacity = 1
                view.layer.shadowRadius = 2.0
                view.clipsToBounds = false
            }
        }

		// 10: vibra o iphone
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		
		// 11: cria um timer que desbloqueia a tela do jogador
        timerBlock = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
//            print("unblock")
            self.unblockClick()
        })
        
    }

}
