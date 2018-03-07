import Foundation
import MultipeerConnectivity


protocol ButtonGameServiceDelegate {
	func addData(manager: ButtonGameService, dataString: String)
	func updateRandom(manager: ButtonGameService, dataString: String)
	func updateData(manager: ButtonGameService, dataString: String)
}

class ButtonGameService: NSObject {
	
	enum Event: String {
		case Add = "Add",
		HostAdd = "HostAdd",
		Random = "Random",
		Update = "Update"
	}
	
	private let ClickServiceType = "button-game"
	let myPeerId = MCPeerID(displayName: UIDevice.current.name)
	private let service: MCNearbyServiceAdvertiser
	private let browser: MCNearbyServiceBrowser
	var sessionInitTime = Date()
	var delegate: ButtonGameServiceDelegate?
	var isHost = true
	var didUpdate = true
	var hostID: MCPeerID!
	
	lazy var session: MCSession = {
		let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	override init() {
		self.service = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: self.ClickServiceType)
		self.browser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: self.ClickServiceType)
		super.init()
		self.service.delegate = self
		self.service.startAdvertisingPeer()
		self.browser.delegate = self
		self.browser.startBrowsingForPeers()
	}
	
	deinit {
		self.service.stopAdvertisingPeer()
		self.browser.stopBrowsingForPeers()
	}
	
	@objc private func startAdvertising() {
		if !self.isHost {
			self.isHost = true
			self.service.delegate = self
			self.service.startAdvertisingPeer()
		}
	}
	
	private func startBrowsing() {
		self.browser.delegate = self
		self.browser.startBrowsingForPeers()
	}
	
	func send(peerData: [String:String]) {
		NSLog("peerData: \(peerData) to \(session.connectedPeers.count) peers")
		if session.connectedPeers.count > 0 {
			do {
				let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
				try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
			}
			catch let error {
				NSLog("Error for sending: \(error)")
			}
		}
	}
	func replicateToHost(peerData: [String:String]) {
		NSLog("peerData: \(peerData) to \(session.connectedPeers.count) peers")
		//		if session.connectedPeers.count > 0 {
		do {
			let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
			try self.session.send(data, toPeers: [self.hostID], with: .reliable)
		}
		catch let error {
			NSLog("Error for sending: \(error)")
		}
		//		}
	}
	
}

extension ButtonGameService: MCNearbyServiceAdvertiserDelegate {
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		print("didNotStartAdvertisingPeer \(error)")
	}
	
	//	This code accepts all incoming connections automatically.
	//	To keep sessions private the user should be notified and asked to confirm incoming connections. This can be implemented using the MCAdvertiserAssistant classes.
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
		print("didReceiveInvitationFromPeer \(peerID)")
		var hostTimer = TimeInterval()
		if let hostContext = context {
			hostTimer = hostContext.withUnsafeBytes { (ptr: UnsafePointer<TimeInterval>) -> TimeInterval in
				return ptr.pointee
			}
		}
		let peerRunningTime = -sessionInitTime.timeIntervalSinceNow
		let isPeerOlder = (hostTimer > peerRunningTime)
		invitationHandler(isPeerOlder, self.session)
		if isPeerOlder {
			print(#line, "accepting invitation from \(peerID)")
			self.browser.stopBrowsingForPeers()
			self.isHost = false
			self.hostID = peerID
		}
		//        invitationHandler(true, self.session)
	}
}

extension ButtonGameService: MCNearbyServiceBrowserDelegate {
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		print("lostPeer \(peerID)")
	}
	
	//	This code invites any peer automatically. The MCBrowserViewController class could be used to scan for peers and invite them manually.
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		print("foundPeer \(peerID)")
		print("invitePeer \(peerID)")
		let toUseSession = self.session
		var runningTime = -sessionInitTime.timeIntervalSinceNow
		let data = Data(buffer: UnsafeBufferPointer(start: &runningTime, count: 1))
		browser.invitePeer(peerID, to: toUseSession, withContext: data, timeout: 20)
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		print("didNotStartBrowsingForPeers \(error)")
	}
	
}

extension ButtonGameService: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		print("peer: \(peerID), didChangeState: \(state)")
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		print("didReceiveData: \(data)")
		if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String:String] {
			if result["event"] == Event.Add.rawValue && isHost {
				if result.count == 2 {
					self.delegate?.addData(manager: self, dataString: result["data"]!)
				} else {
					if !self.didUpdate {
						self.delegate?.addData(manager: self, dataString: result["data"]!)
						self.didUpdate = true
					}
				}
			}
			if result["event"] == Event.Update.rawValue {
				self.delegate?.updateData(manager: self, dataString: result["data"]!)
			}
			if result["event"] == Event.HostAdd.rawValue {
				var replicateData = [String:String]()
				replicateData["event"] = ColorServiceManager.Event.Add.rawValue
				replicateData["replicate"] = "replicate"
				replicateData["data"] = result["data"]!
				self.replicateToHost(peerData: replicateData)
			}
			if result["event"] == Event.Random.rawValue {
				self.delegate?.updateRandom(manager: self, dataString: result["data"]!)
			}
		}
	}
	
	func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
		print("didReceiveStream")
	}
	
	func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
		print("didFinishReceivingResourceWithName")
	}
	
	func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
		print("didFinishReceivingResourceWithName")
	}
}


