//
//  SubscribeViewController.swift
//  AWSIoTDemo
//
//  Created by Itsuki on 2024/03/03.
//

import UIKit
import AWSIoT


class SubscribeViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tabBarViewController = self.tabBarController as! TabBarController

        topicLabel.text = "Topic: \(TOPIC_NAME)"
        statusLabel.text = "\(tabBarViewController.connectingStatusText)"
    }
    
    @IBAction func onSubscribeButtonPressed(_ sender: UIButton) {
        subscribe()
    }
    
    @IBAction func onUnsubscribeButtonPressed(_ sender: UIButton) {
        unSubscribe()
    }

}


extension SubscribeViewController {
    
    func messageReceived(payload: Data) {
        DispatchQueue.main.async {
            if let jsonData = self.jsonDataToDict(jsonData: payload) {
                print("Message received: \(jsonData)")
                self.messageLabel.text = "jsonData received:\n\(jsonData)"
            } else {
                let stringData: String = String(decoding: payload, as: UTF8.self)
                print("Message received: \(stringData)")
                self.messageLabel.text = "stringData received:\n\(stringData)"
            }
        }
    }
    
    
    func jsonDataToDict(jsonData: Data?) -> Dictionary<String, Any>? {
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            let convertedDict = jsonDict as! [String: Any]
            return convertedDict
        } catch {
            return nil
        }
    }
    
    func subscribe() {
        let iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)
        iotDataManager.subscribe(toTopic: TOPIC_NAME,
                                 qoS: .messageDeliveryAttemptedAtLeastOnce,
                                 messageCallback: messageReceived)
    }

    func unSubscribe() {
        let iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)
        iotDataManager.unsubscribeTopic(TOPIC_NAME)
    }
}
