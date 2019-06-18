//
//  UartModuleViewController.swift
//  Bubble
//






import UIKit
import CoreBluetooth

class UartModuleViewController: UIViewController, CBPeripheralManagerDelegate, UITextFieldDelegate {
    
    //UI
    //Data    
    var peripheralManager: CBPeripheralManager?
//    var peripheral: CBPeripheral!
    var selectedButton = UIButton()
    var valve = ""
    var buttonState = 1
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var batterLevel: UILabel!
    @IBOutlet weak var batteryIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Disconnect", style:.plain, target:nil, action:nil)
        self.navigationItem.title = "Controller"
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
        
        
        
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @IBAction func actionToggle(_ toggle: UIButton) {
        if buttonState == 0 {
            buttonState = 1
            actionButton.setTitle("Inflate", for: .normal)
            actionButton.backgroundColor = UIColor(red:0.94, green:0.89, blue:0.64, alpha:1.0)
        }
        else if buttonState == 1 {
            buttonState = 0
            actionButton.setTitle("Deflate", for: .normal)
            actionButton.backgroundColor = UIColor(red:0.89, green:0.59, blue:0.55, alpha:1.0)
        }
    }

    
    
    
    @IBAction func released(_ sender: UIButton) {
        if valve != "" {
            print("!" + valve)
            writeValue(data: "!" + valve)
        }
    }
    
    @IBAction func pressed(_ sender: UIButton) {
        valve = String(sender.tag)
        if valve != "" {
            if buttonState == 1 {
                print(">" + valve)
                writeValue(data: ">" + valve)
            }
            else {
                print("<" + valve)
                writeValue(data: "<" + valve)
            }
        }
        
    }
    func setBattery() {
        if batterLevel.text != String(batteryPercent) {
            if batteryPercent == -1 {
                batterLevel.text = "N/A"
            }
            else{
                batterLevel.text = String(batteryPercent) + "%"

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
    
    func setValve(button: UIButton, valveValue: String) {
        if selectedButton != button {
            selectedButton.isSelected = false
            selectedButton = button
        }
        
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            valve = valveValue
        }
        else {
            valve = ""
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
    
//    func readCharacteristic() -> String {
//
//        if let data = rxCharacteristic?.value {
//            return String(data: data, encoding: String.Encoding.ascii) ?? ""
//        }
//        else {
//            return "None"
//        }
//
//
//    }
    
    func updateIncomingData () {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Notify"), object: nil , queue: nil){
            notification in
            batteryPercent = Int(characteristicData) ?? -1
            self.setBattery()
            
        }
    }
    
    
    
    
    //MARK: UITextViewDelegate methods
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            return
        }
        print("Peripheral manager is running")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Device subscribe to characteristic")
    }
}
    
    //This on/off switch sends a value of 1 and 0 to the Arduino
    //This can be used as a switch or any thing you'd like
//    @IBAction func switchAction(_ sender: Any) {
//        if switchUI.isOn {
//            print("On ")
//            writeCharacteristic(val: 1)
//        }
//        else
//        {
//            print("Off")
//            writeCharacteristic(val: 0)
//            print(writeCharacteristic)
//        }
//    }
//    
//    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
//        if let error = error {
//            print("\(error)")
//            return
//        }
//    }

