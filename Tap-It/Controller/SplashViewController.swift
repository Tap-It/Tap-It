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
        
        var width = view.frame.width*0.6
        let height = width*0.92

        let logoImage = UIImageView()
        logoImage.image = UIImage(named: "logo")
        logoImage.frame = CGRect(x: view.frame.midX-(width/2), y: view.frame.midY-(height/1.5), width: width, height: height)
        view.addSubview(logoImage)
		
        width = width/3
        
        let name = UILabel()
        name.text = "Tap It!"
        name.font = UIFont(name: "Janda Safe and Sound Solid", size: 60)
        name.adjustsFontSizeToFitWidth = true
        name.minimumScaleFactor = 0.1
        name.numberOfLines = 0

        name.frame = CGRect(x: logoImage.frame.midX-(width/2), y: logoImage.frame.maxY*1.1, width: width, height: width*0.51)
        
        view.addSubview(name)

		Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(enterWatingRoom), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@objc func enterWatingRoom() {
		self.performSegue(withIdentifier: "waiting", sender: nil)
	}
}
