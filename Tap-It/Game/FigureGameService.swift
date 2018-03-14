import Foundation
import MultipeerConnectivity


protocol FigureGameServiceDelegate {
	func receive(_ data: Any)
	func receivee(_ data:Data)
	func startGame()
	func addPlayer(name:String, serviceId:Int)
	func removePlayer(serviceId:Int)
	func lostHost()
}

class FigureGameService: NSObject {
	
	private let ClickServiceType = "figure-game"
	let myPeerId:MCPeerID!
	private let service: MCNearbyServiceAdvertiser
	private let browser: MCNearbyServiceBrowser
	var sessionInitTime = Date()
	var delegate: FigureGameServiceDelegate?
	var isHost = true
	var didUpdate = true
	var hostID: MCPeerID!

	lazy var session: MCSession = {
		let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
		session.delegate = self
		return session
	}()
	
	init(playerName:String) {
		self.myPeerId = MCPeerID(displayName: playerName)
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
	
	private func replicateFromHost(_ peerData: [String:String]) {
		do {
			let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
			try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
		}
		catch let error {
			NSLog("Error for sending: \(error)")
		}
	}
	
}

extension FigureGameService: MCNearbyServiceAdvertiserDelegate {
	
	func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
		print("didNotStartAdvertisingPeer \(error)")
	}
	
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
	}
}

extension FigureGameService: FigureServiceProtocol {
	
	func getHashFromPeer() -> Int {
		return self.myPeerId.hashValue
	}
	
	// TODO: create a method that will rename the peer id name
	
	func stopAdvertising() {
		self.service.stopAdvertisingPeer()
	}

	func shouldStartGame() {
		if isHost {
			delegate?.startGame()
			self.browser.stopBrowsingForPeers()
		}
	}
	
	func setDelegate(_ gameManager: FigureGameManager) {
		self.delegate = gameManager
	}
	
	func send(deck: [Card]) {
		do {
			let data = NSKeyedArchiver.archivedData(withRootObject: deck)
			try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
		}
		catch let error {
			NSLog("Error for sending: \(error)")
		}
		self.delegate?.receive(deck)
	}

	func send(peerData: [String:Any]) {
		if let event = peerData["event"] as? Int {
			switch event {
			case Event.JoinGame.rawValue:
				if isHost {
					self.delegate?.receive(peerData)
				} else {
					do {
						let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
						try self.session.send(data, toPeers: [hostID], with: .reliable)
					}
					catch let error {
						NSLog("Error for sending: \(error)")
					}
				}
			case Event.Peers.rawValue, Event.Startgame.rawValue:
				if isHost {
					do {
						let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
						try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
					}
					catch let error {
						NSLog("Error for sending: \(error)")
					}
					delegate?.receive(peerData)
				}
			case Event.PlayerId.rawValue:
				let serviceId = peerData["peer"] as? Int
				if serviceId! == self.myPeerId.hashValue {
					delegate?.receive(peerData)
				} else {
					do {
						let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
						try self.session.send(data, toPeers: [self.getPeerId(serviceId: serviceId!)!], with: .reliable)
					}
					catch let error {
						NSLog("Error for sending: \(error)")
					}
				}
			default:
				return
			}
		}
	}
	
	func sendBlob(_ data: [String:Any]) {
		if let event = data["event"] as? Int {
			switch event {
			case Event.Card.rawValue:
				if isHost {
					if let player = data["data"] as? Player {
						let dict = ["event":Event.Card.rawValue ,"data":player.cards.last!]
						if player.serviceId == self.myPeerId.hashValue {
							delegate?.receive(dict)
						} else {
							guard let peer = self.getPeerId(serviceId: player.serviceId!) else {
								print("Fatal error")
								return
							}
							do {
								let data = NSKeyedArchiver.archivedData(withRootObject: dict)
								try self.session.send(data, toPeers: [peer], with: .reliable)
							}
							catch let error {
								NSLog("Error for sending: \(error)")
							}
						}
					}
				}
			case Event.Deck.rawValue:
				if isHost {
					do {
						let data = NSKeyedArchiver.archivedData(withRootObject: data)
						try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
					}
					catch let error {
						NSLog("Error for sending: \(error)")
					}
					delegate?.receive(data)
				}
            case Event.Click.rawValue:
                if !isHost {
                    do {
                        let data = NSKeyedArchiver.archivedData(withRootObject: data)
                        try self.session.send(data, toPeers: [hostID], with: .reliable)
                    }
                    catch let error {
                        NSLog("Error for sending: \(error)")
                    }
                } else {
                    delegate?.receive(data)
                }
			default:
				return
			}
		}
	}
	
	func sendBlobb(_ data: Data) {
		if !isHost {
			do {
				try self.session.send(data, toPeers: [hostID], with: .reliable)
			}
			catch let error {
				NSLog("Error for sending: \(error)")
			}
		} else {
			delegate?.receive(data)
		}
	}
	
	func getName() -> String {
		return myPeerId.displayName
	}
	
	private func getPeerId(serviceId: Int) -> MCPeerID? {
		for peer in session.connectedPeers {
			if peer.hashValue == serviceId {
				return peer
			}
		}
		return nil
	}
}

extension FigureGameService: MCNearbyServiceBrowserDelegate {
	
	func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		print("lostPeer \(peerID)")
		delegate?.removePlayer(serviceId: peerID.hashValue)
	}
	
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

extension FigureGameService: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		print("peer: \(peerID), didChangeState: \(state)")
		if state == .connected {
			// TODO: make sure to avoid duplicate names
			delegate?.addPlayer(name: peerID.displayName, serviceId:peerID.hashValue)
		}
		if state == .notConnected {
			if peerID == self.hostID {
				delegate?.lostHost()
			}
		}
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		print("didReceiveData: \(data)")
		
		self.delegate?.receivee(data)

		if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String:Any] {
			delegate?.receive(result)
		}
		
		if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Card] {
			delegate?.receive(result)
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
