import Foundation
import MultipeerConnectivity

protocol ColorServiceManagerDelegate {
	func connectedDevicesChanged(manager : ColorServiceManager, connectedDevices: [String])
	func colorChanged(manager : ColorServiceManager, colorString: String)
}

class ColorServiceManager: NSObject {
	
	private let ClickServiceType = "example-click"
	private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
	private let service: MCNearbyServiceAdvertiser
	private let browser: MCNearbyServiceBrowser
	var sessionInitTime = Date()
	var delegate: ColorServiceManagerDelegate?
	var isHost = false
	
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
	
	func send(colorName : String) {
		NSLog("sendColor: \(colorName) to \(session.connectedPeers.count) peers")
		if session.connectedPeers.count > 0 {
			do {
				try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
			}
			catch let error {
				NSLog("Error for sending: \(error)")
			}
		}
	}
	
}

extension ColorServiceManager: MCNearbyServiceAdvertiserDelegate {
	
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
		}
		invitationHandler(true, self.session)
	}
}

extension ColorServiceManager: MCNearbyServiceBrowserDelegate {
	
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

extension ColorServiceManager: MCSessionDelegate {
	
	func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
		print("peer: \(peerID), didChangeState: \(state)")
		self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
			session.connectedPeers.map{$0.displayName})
	}
	
	func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
		print("didReceiveData: \(data)")
		let str = String(data: data, encoding: .utf8)!
		self.delegate?.colorChanged(manager: self, colorString: str)
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

