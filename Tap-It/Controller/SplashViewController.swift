import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		let gradientLayer = CAGradientLayer()
		let topColor = UIColor(red: 250.0/255.0, green: 215.0/255.0, blue: 95.0/255.0, alpha: 1.0).cgColor
		let bottomColor = UIColor(red: 245.0/255.0, green: 125.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
		gradientLayer.colors = [topColor, bottomColor]
		gradientLayer.frame = view.frame
		view.layer.insertSublayer(gradientLayer, at: 0)
		
		Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(enterWatingRoom), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@objc func enterWatingRoom() {
		self.performSegue(withIdentifier: "waiting", sender: nil)
	}
}
