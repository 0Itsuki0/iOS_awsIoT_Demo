//
//  ConnectionViewController.swift
//  AWSIoTDemo
//
//  Created by Itsuki on 2024/03/03.
//
import AWSIoT
import UIKit

class ConnectionViewController: UIViewController {

    var iotDataManager: AWSIoTDataManager!
    var credentialsProvider: AWSCognitoCredentialsProvider!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("initialzing credential provider")
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWS_REGION, identityPoolId:IDENTITY_POOL_ID)
        
        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
        let iotDataConfiguration = AWSServiceConfiguration(region: AWS_REGION, endpoint: iotEndPoint, credentialsProvider: credentialsProvider)

        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: AWS_IOT_DATA_MANAGER_KEY)
        iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBarViewController = self.tabBarController as! TabBarController

        statusLabel.text = "\(tabBarViewController.connectingStatusText)"
    }
    
    @IBAction func onConnectButtonPressed(_ sender: UIButton) {
        Task {
            let clientId = await getAWSClientID()
            connectToIoT(clientId: clientId!)
        }
        
    }
    
    @IBAction func onDisconnectButtonPressed(_ sender: UIButton) {
        disconnectIoT()
    }

}



extension ConnectionViewController {
    
    private func getAWSClientID(completion: @escaping (_ clientId: String?,_ error: Error? ) -> Void) {
        credentialsProvider.getIdentityId().continueWith(block: { (task:AWSTask<NSString>) -> Any? in
            if let error = task.error as NSError? {
                print("error: \(error)")
                completion(nil, error)
                return nil
            }
            
            let clientId = task.result! as String
            print("client ID: \(clientId)")
            completion(clientId, nil)
            return nil
        })
    }
    
    
    func getAWSClientID() async -> String? {
        return await withCheckedContinuation { continuation in
            getAWSClientID { clientId, error in
                continuation.resume(returning: clientId)
            }
        }
    }
    
    
    func connectToIoT(clientId: String){
        print("Attempting to connect to IoT device gateway with ID = \(clientId)")
        let connectionResult = iotDataManager.connectUsingWebSocket(withClientId: clientId,
                                          cleanSession: true,
                                          statusCallback: mqttEventCallback)
        print("connectionResult: \(connectionResult)")
    }
    
    
    func disconnectIoT() {
        self.iotDataManager.disconnect()
    }
    
    
    func mqttEventCallback( _ status: AWSIoTMQTTStatus ) {
        DispatchQueue.main.async {
            let tabBarViewController = self.tabBarController as! TabBarController
            
            print("status \(status.rawValue)")
            if (status != .connected || status != .connecting) {
                tabBarViewController.selectedIndex = 0
            }
            
            switch status {
            case .connecting:
                print("connecting")
                tabBarViewController.connectingStatusText = "connecting"
                self.statusLabel.text = "connecting"
                
            case .connected:
                print("connected")
                tabBarViewController.connectingStatusText = "connected"
                self.statusLabel.text = "connected"

            case .connectionError:
                print("connectionError")
                tabBarViewController.connectingStatusText = "connectionError"
                self.statusLabel.text = "connectionError"

            case .connectionRefused:
                print("connectionRefused")
                tabBarViewController.connectingStatusText = "connectionRefused"
                self.statusLabel.text = "connectionRefused"

            case .disconnected:
                print("disconnected")
                tabBarViewController.connectingStatusText = "disconnected"
                self.statusLabel.text = "disconnected"

            case .protocolError:
                print("protocolError")
                tabBarViewController.connectingStatusText = "protocolError"
                self.statusLabel.text = "protocolError"

            case .unknown:
                print("unknown")
                tabBarViewController.connectingStatusText = "unknown"
                self.statusLabel.text = "unknown"

            default:
                print("default ")
                tabBarViewController.connectingStatusText = "default unknown"
                self.statusLabel.text = "default"

            }
        }
    }
}

