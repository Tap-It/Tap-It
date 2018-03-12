import UIKit

class WaitingRoomViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var playButton: UIButton!
	var data = [String]() {
		didSet {
			self.tableView.reloadData()
		}
	}
	let manager = FigureGameManager()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.manager.delegateWatingRomm = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func handleClick(_ sender: UIButton) {
	}
}

extension WaitingRoomViewController: GameManagerWaitingRoomProtocol {
	func updateConnectedPeers(name: String) {
	}
	
	func updateConnectedPeers(names: [String]) {
		self.data = names
	}
	
	
}
