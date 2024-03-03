//
//  TabBarController.swift
//  AWSIoTDemo
//
//  Created by Itsuki on 2024/03/03.
//

import UIKit
import AWSIoT

class TabBarController: UITabBarController {
    var connectingStatusText: String = "disconnected"
    
    var connectingStatus: AWSIoTMQTTStatus = .disconnected

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
