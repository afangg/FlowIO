//
//  UartModuleViewController.swift
//  Bubble
//

import UIKit
import CoreBluetooth

class RemoteViewController: UIViewController, CBPeripheralManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
       
    var peripheralManager: CBPeripheralManager?
    var selectedButton = UIButton()
    var valve = ""
    var communicationProtocol = ["Inflate": "+", "Vacuum": "-", " Release": "^", "Inflate2x": "P", "Vacuum2x": "N"]
    var states: [String] = []


    @IBOutlet weak var batterLevel: UILabel!
    @IBOutlet weak var batteryIcon: UIImageView!
    @IBOutlet weak var statePicker: UIPickerView!
    @IBOutlet weak var portButtons: UIStackView!
    @IBOutlet weak var stateField: UITextField!
    
    @IBAction func released(_ sender: UIButton) {
        if valve != "" {
            print("!" + valve)
            writeValue(data: "!" + valve)
        }
    }
    
    @IBAction func pressed(_ sender: UIButton) {
        valve = String(sender.tag)
        var selectedState = statePicker.selectedRow(inComponent: 0)
        if valve != "" {
            writeValue(data: communicationProtocol[states[selectedState]]! + valve)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statePicker.delegate = self
        statePicker.dataSource = self
        statePicker.isHidden = true
        stateField.delegate = self
        
        states = Array(communicationProtocol.keys)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Disconnect", style:.plain, target:self, action:Selector("disconnect"))
        //Create and start the peripheral manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        //-Notification for updating the text view with incoming text
        updateIncomingData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Avenir Next", size: 21)
        label.text =  states[row]
        label.textAlignment = .center
        return label
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateField.text = states[row]
        pickerView.isHidden = true
        stateField.isHidden = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        stateField.isHidden = true
        statePicker.isHidden = false
        return false
    }
    

    
    func setBattery() {
        //print("Setting battery")

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
    
    func updateIncomingData () {
        print("Waiting for battery data")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "Battery"), object: nil , queue: nil){
            notification in
            batteryPercent = Int(batteryData) ?? -1
            self.setBattery()
            
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
    
}
    

