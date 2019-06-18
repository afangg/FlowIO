//
//  ControllerMenu.swift
//  Bubble
//
//  Created by Alisha Fong on 6/6/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class ControllerMenu: UIViewController {
//    var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Disconnect", style:.plain, target:nil, action:nil)
        
        self.navigationItem.title = "Menu"


        // Do any additional setup after loading the view.
    }
    
    @IBAction func remoteControlSegue(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uartVC = storyboard.instantiateViewController(withIdentifier: "UartModuleViewController") as! UartModuleViewController
        
//        uartVC.peripheral = peripheral
        navigationController?.pushViewController(uartVC, animated: true)
    }
    
}
