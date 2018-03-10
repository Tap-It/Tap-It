//
//  FigureViewController.swift
//  Tap-It
//
//  Created by Fernando Zanei on 2018-03-09.
//  Copyright © 2018 Tap It. All rights reserved.
//

import UIKit

class FigureViewController: UIViewController {
    
    @IBOutlet weak var figure0: UIImageView!
    @IBOutlet weak var figure1: UIImageView!
    @IBOutlet weak var figure2: UIImageView!
    @IBOutlet weak var figure3: UIImageView!
    @IBOutlet weak var figure4: UIImageView!
    @IBOutlet weak var figure5: UIImageView!
    @IBOutlet weak var figure6: UIImageView!
    @IBOutlet weak var figure7: UIImageView!
    
    let gameManager = FigureGameManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameManager.delegate = self
        
    }
    
}

extension FigureViewController : FigureProtocol {
    func updateDeck(_ card: Card) {
        DispatchQueue.main.async {
            self.figure0.image = card.face[0].loadImage()
            self.figure1.image = card.face[1].loadImage()
            self.figure2.image = card.face[2].loadImage()
            self.figure3.image = card.face[3].loadImage()
            self.figure4.image = card.face[4].loadImage()
            self.figure5.image = card.face[5].loadImage()
            self.figure6.image = card.face[6].loadImage()
            self.figure7.image = card.face[7].loadImage()
        }
        
    }
}
