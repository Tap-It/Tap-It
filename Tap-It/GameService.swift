import Foundation
import MultipeerConnectivity


protocol GameServiceDelegate {
    func receive(_ data: [String:String])
    func startGame()
	func addPlayer(player: String)
	func removePlayer(player: String)
}

class GameService: NSObject {
    
    private let ClickServiceType = "button-game"
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let service: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    var sessionInitTime = Date()
    var delegate: GameServiceDelegate?
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

extension GameService: MCNearbyServiceAdvertiserDelegate {
    
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

extension GameService: ServiceProtocol {
    
    func setDelegate(_ gameManager: GameManager) {
        self.delegate = gameManager
    }
    
    func send(_ peerData: [String:String]) {
        let event = peerData["event"]!
        switch event {
        case Event.Click.rawValue:
            var peers = [MCPeerID]()
            if !isHost {
                peers = [hostID]
            } else {
                peers = session.connectedPeers
                delegate?.receive(peerData)
            }
            
            do {
                let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
                try self.session.send(data, toPeers: peers, with: .reliable)
            }
            catch let error {
                NSLog("Error for sending: \(error)")
            }
            
        case Event.Update.rawValue:
            if isHost {
                do {
                    let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
                    try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
                    delegate?.receive(peerData)
                }
                catch let error {
                    NSLog("Error for sending: \(error)")
                }
            }
			
		case Event.Score.rawValue:
			if isHost {
				do {
					let data = NSKeyedArchiver.archivedData(withRootObject: peerData)
					try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
					delegate?.receive(peerData)
				}
				catch let error {
					NSLog("Error for sending: \(error)")
				}
			}
			
        default:
            return
        }
    }
    
    func getName() -> String {
        return myPeerId.displayName
    }
    
}

extension GameService: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer \(peerID)")
		delegate?.removePlayer(player: peerID.displayName)
    }
    
    //    This code invites any peer automatically. The MCBrowserViewController class could be used to scan for peers and invite them manually.
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

extension GameService: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer: \(peerID), didChangeState: \(state)")
        if isHost {
            delegate?.startGame()
        }
		delegate?.addPlayer(player: peerID.displayName)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        // AQUI
        
        if let result = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String:String] {
            if isHost {
                self.replicateFromHost(result)
            }
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



