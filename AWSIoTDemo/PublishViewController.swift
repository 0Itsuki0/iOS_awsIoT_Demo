//
//  PublishViewController.swift
//  AWSIoTDemo
//
//  Created by Itsuki on 2024/03/03.
//

import UIKit
import AWSIoT

class PublishViewController: UIViewController {
    
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBarViewController = self.tabBarController as! TabBarController

        topicLabel.text = "Topic: \(TOPIC_NAME)"
        statusLabel.text = "\(tabBarViewController.connectingStatusText)"
    }
    
    @IBAction func onPublishButtonPressed(_ sender: UIButton) {
        let currentTime = Date().ISO8601Format()
        publishData(message: "Hello from \(currentTime)")
    }
    
    
}

extension PublishViewController {
    func publishString(message: String) {
        let iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)
        // @param qos The QoS value to use when publishing (optional, default AWSIoTMQTTQoSAtMostOnce).
        let result = iotDataManager.publishString(message, onTopic: TOPIC_NAME, qoS: .messageDeliveryAttemptedAtLeastOnce)
        print("publish result: \(result)")
    }

    
    func publishData(message: String) {
        let iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)

        let payload = [
            "message": message
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: [])
        // @param qos The QoS value to use when publishing (optional, default AWSIoTMQTTQoSAtMostOnce).
        let result = iotDataManager.publishData(jsonData, onTopic: TOPIC_NAME, qoS: .messageDeliveryAttemptedAtLeastOnce)
        print("publish result: \(result)")
        
    }

}
