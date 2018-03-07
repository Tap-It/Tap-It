import UIKit

class ViewController: UIViewController {
	
    var data = [String]() {
        didSet {
            let indexPath = IndexPath(item: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.top)
        }
    }
	let colorService = ColorServiceManager()
	
	@IBOutlet weak var tableView: UITableView!
	override func viewDidLoad() {
		super.viewDidLoad()
		colorService.delegate = self
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    @IBAction func addTapped() {
        let peerName = colorService.session.myPeerID.displayName
        let string = "\(peerName) - \(Date())"
		var data = [String:String]()
		if colorService.isHost {
			data["event"] = ColorServiceManager.Event.HostAdd.rawValue
			colorService.didUpdate = false
			data["replicate"] = "replicate"
		} else {
			data["event"] =  ColorServiceManager.Event.Add.rawValue
		}
        data["data"] = string
        colorService.send(peerData: data)
    }
	
	func change(color : UIColor) {
		UIView.animate(withDuration: 0.2) {
			self.view.backgroundColor = color
		}
	}
	
}

extension ViewController : ColorServiceManagerDelegate {
	
	func connectedDevicesChanged(manager: ColorServiceManager, connectedDevices: [String]) {
		OperationQueue.main.addOperation {
            for device in connectedDevices {
                self.data.append(device)
            }
//            self.data = connectedDevices
			self.tableView.reloadData()
		}
	}
    
    func addData(manager: ColorServiceManager, dataString: String) {
        OperationQueue.main.addOperation {
            var data: [String:String] = ["event": ColorServiceManager.Event.Update.rawValue]
            data ["data"] = dataString
            
            self.colorService.send(peerData: data)
			self.data.insert(dataString, at: 0)
        }
    }

    func updateData(manager: ColorServiceManager, dataString: String) {
        OperationQueue.main.addOperation {
            self.data.insert(dataString, at: 0)
        }
    }

}

extension ViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let selected = self.data[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = selected
//        cell.backgroundColor = UIColor.random()
		return cell
	}
}

extension CGFloat {
	static func random() -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UInt32.max)
	}
}

extension UIColor {
	static func random() -> UIColor {
		return UIColor(red:   .random(),
					   green: .random(),
					   blue:  .random(),
					   alpha: 1.0)
	}
}
