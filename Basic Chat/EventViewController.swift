//
//  EventViewController.swift
//  FlowIO
//
//  Created by Alisha Fong on 9/30/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class Event {
    var action = ""
    var port = 0
    var duration = 0
    
    init(action: String, port: Int, duration: Int) {
        self.action = action
        self.port = port
        self.duration = duration
    }
    
}

class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var runButton: UIButton!
    @IBOutlet weak var eventTableView: UITableView!
    
    var events: [Event] = []
    var running = false
    var lastPort = 0
    var actions = ["Inflate", "Vacuum", "Release", "Stop"]
    var codes = ["Inflate": "+", "Vacuum": "-", "Release": "^", "Stop": "!"]
    var actionKey = ["+", "-", "^", "!"]
    var port = [1,2,3,4,5,6]
    var duration = [1,2,5,10,20,30]
    var eventPicker = UIPickerView()
    let eventField = UITextField()

    @IBAction func addEvent(_ sender: UIButton) {
        eventField.becomeFirstResponder()
            
    }
    @IBAction func runEvents(_ sender: UIButton) {
        if running {
            stop()
            runButton.titleLabel?.text = "Run"
        }
        else {
            running = true
            runButton.titleLabel?.text = "Stop"
            run()
//            sender.titleLabel?.text = "Run"

        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPicker()
        eventTableView.delegate = self
        eventTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        eventField.becomeFirstResponder()
        return true

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            events.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventTableViewCell
        
        cell.actionLabel.text = events[indexPath.row].action
        cell.portLabel.text = String(events[indexPath.row].port)
        cell.durationlabel.text = String(events[indexPath.row].duration)

        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0  {
            return actions.count
        }
        else if component == 1 {
            return port.count
        }
        else {
            return duration.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0  {
            return actions[row]
        }
        else if component == 1 {
            return String(port[row])
        }
        else {
            return String(duration[row])
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let a = actions[eventPicker.selectedRow(inComponent: 0)]
        let p = port[eventPicker.selectedRow(inComponent: 1)]
        let d = duration[eventPicker.selectedRow(inComponent: 2)]
        events.append(Event(action: a, port: p, duration: d))
        eventTableView.reloadData()
    }
    
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func createPicker() {
        eventPicker.delegate = self
        eventPicker.dataSource = self
        eventField.delegate = self
        eventField.inputView = eventPicker
        view.addSubview(eventField)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        //Customizations
        toolBar.barTintColor = .black
        toolBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EventViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.barTintColor = .clear
        
        eventField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func run(i: Int = 0) {
        if (i <= events.count-1) && running{
            writeValue(data: (codes[events[i].action] ?? "!") + String(events[i].port))
            delay(Double(events[i].duration)) {
                print("done")
                self.run(i: i+1)
            }
        }
        else {
            running = false
//            stop()
        }
    }
    func stop() {
        for i in (1...6) {
            writeValue(data: "!" + String(i))
        }
        runButton.titleLabel?.text = "Run"
    }
    
    // Write functions
    func writeValue(data: String){
        print(data)
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
}
    
    
    
    

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


