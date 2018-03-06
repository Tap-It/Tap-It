import UIKit

class ViewController: UIViewController {
	
	var data = [String]()
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
	
	@IBAction func yellowTapped() {
		self.change(color: .yellow)
		colorService.send(colorName: "yellow")
	}
	
	@IBAction func redTapped() {
		self.change(color: .red)
		colorService.send(colorName: "red")
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
			self.data = connectedDevices
			self.tableView.reloadData()
		}
	}
	
	func colorChanged(manager: ColorServiceManager, colorString: String) {
		OperationQueue.main.addOperation {
			switch colorString {
			case "red":
				self.change(color: .red)
			case "yellow":
				self.change(color: .yellow)
			default:
				NSLog("%@", "Unknown color value received: \(colorString)")
			}
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
