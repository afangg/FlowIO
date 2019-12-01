//
//  AllRemoteViewController.swift
//  FlowIO
//
//  Created by Alisha Fong on 10/21/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class AllRemoteViewController: UIViewController, CBPeripheralManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Disconnect", style:.plain, target:self, action:Selector("disconnect"))
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
        // Do any additional setup after loading the view.
    }
    
    var peripheralManager: CBPeripheralManager?
    var inflate = "+"
    var deflate = "-"
    @IBOutlet weak var batteryLevel: UILabel!
    @IBOutlet weak var batteryIcon: UIImageView!
    
    @IBOutlet var inflateButtons: [UIButton]!
    @IBOutlet var deflateButtons: [UIButton]!
    
    
    @IBAction func inflateModes(_ sender: UIButton) {
        if inflate == "+" {
            inflate = "P"
            sender.setTitle("Inflate2x", for: .normal)
            for button in inflateButtons {
                button.backgroundColor = UIColor(red:0.96, green:0.34, blue:0.34, alpha:1.0)
            }
        }
        else {
            inflate = "+"
            sender.setTitle("Inflate", for: .normal)
            for button in inflateButtons {
                button.backgroundColor = UIColor(red:1.00, green:0.59, blue:0.56, alpha:1.0)
            }
        }
    }
    
    @IBAction func deflateModes(_ sender: UIButton) {
        if deflate == "-" {
            deflate = "N"
            sender.setTitle("Vacuum2x", for: .normal)
            for button in deflateButtons {
                button.backgroundColor = UIColor(red:0.51, green:0.81, blue:1.00, alpha:1.0)
            }
        }
        else {
            deflate = "-"
            sender.setTitle("Vacuum", for: .normal)
            for button in deflateButtons {
                button.backgroundColor = UIColor(red:0.77, green:0.88, blue:0.95, alpha:1.0)
            }
        }
    }
    
    @IBAction func inflateValve(_ sender: UIButton) {
        if String(sender.tag) != "" {
            print(inflate + String(sender.tag))
            writeValue(data: inflate + String(sender.tag))
        }
    }
    
    @IBAction func vacuumValve(_ sender: UIButton) {
        if String(sender.tag) != "" {
            print(deflate + String(sender.tag))
            writeValue(data: deflate + String(sender.tag))
        }
    }
    @IBAction func releaseValve(_ sender: UIButton) {
        print("^" + String(sender.tag))
        if String(sender.tag) != "" {
            writeValue(data: "^" + String(sender.tag))
        }
    }
    
    @IBAction func released(_ sender: UIButton) {
        if String(sender.tag) != "" {
            print("!" + String(sender.tag))
            writeValue(data: "!" + String(sender.tag))
        }
    }
    
    // Write functions
    func writeValue(data: String){
        let valueString = (data as NSString).data(using: String.Encoding.ascii.rawValue)
        //change the "data" to valueString
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func writeCharacteristic(val: Int8){
        var val = val
        let ns = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
        blePeripheral!.writeValue(ns as Data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    func updateIncomingData () {
        print("Waiting for battery data")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Battery"), object: nil , queue: nil){
            notification in
            batteryPercent = Int(batteryData) ?? -1
            self.setBattery()
            
        }
    }
    func setBattery() {
        //print("Setting battery")

        if batteryLevel.text != String(batteryPercent) {
            if batteryPercent == -1 {
                batteryLevel.text = "N/A"
            }
            else{
                batteryLevel.text = String(batteryPercent) + "%"

            }
            
            if batteryPercent > 75 {
                batteryIcon.image = UIImage(named: "100")
            }
            else if batteryPercent > 50 {
                batteryIcon.image = UIImage(named: "75")
            }
            else if batteryPercent > 25 {
                batteryIcon.image = UIImage(named: "50")
            }
            else {
                batteryIcon.image = UIImage(named: "25")
            }
        }
        
    }
    
    func disconnect() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let uartVC = storyboard.instantiateViewController(withIdentifier: "BLECentralViewController") as! BLECentralViewController
        
        //        uartVC.peripheral = peripheral
        navigationController?.popToRootViewController(animated: true)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            let appendString = "\n"
            let myFont = UIFont(name: "Helvetica Neue", size: 15.0)
            let myAttributes2 = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): myFont!, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.red]
            let attribString = NSAttributedString(string: "[Incoming]: " + (characteristicASCIIValue as String) + appendString, attributes: convertToOptionalNSAttributedStringKeyDictionary(myAttributes2))
            let newAsciiText = NSMutableAttributedString(attributedString: self.consoleAsciiText!)
            self.baseTextView.attributedText = NSAttributedString(string: characteristicASCIIValue as String , attributes: convertToOptionalNSAttributedStringKeyDictionary(myAttributes2))
            
            newAsciiText.append(attribString)
            
            self.consoleAsciiText = newAsciiText
            self.baseTextView.attributedText = self.consoleAsciiText
            
        }
    }

}
