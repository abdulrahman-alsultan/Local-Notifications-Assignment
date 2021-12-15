//
//  ViewController.swift
//  Local Notifications Assignment
//
//  Created by admin on 14/12/2021.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    @IBOutlet weak var minutesPicker: UIPickerView!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var minTimer: UILabel!
    @IBOutlet weak var workUntil: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var starterBtn: UIButton!
    
    let minutes = ["5 Minutes", "10 Minutes", "20 Minutes", "30 Minutes"]
    var actions: [String] = []
    
    var idx = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        minutesPicker.dataSource = self
        minutesPicker.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        totalTime.text = "Total Time:"
        time.text = "0 hours, 0 min"
        minTimer.text = ""
        workUntil.text = ""
    }
    
    
    
    
    func hiddinViews(hiddin: Bool){
        tableView.isHidden = !hiddin
        totalTime.isHidden = hiddin
        minTimer.isHidden = hiddin
        minutesPicker.isHidden = hiddin
        workUntil.isHidden = hiddin
        time.isHidden = hiddin
        starterBtn.isHidden = hiddin
    }
    
    
    @IBAction func startTimer(_ sender: Any) {
        var timeSelected = 5
        switch(idx){
        case 0: timeSelected = 5
        case 1: timeSelected = 10
        case 2: timeSelected = 20
        case 3: timeSelected = 30
        default: print("")
        }
        
        totalTime.text = "Total Time: \(timeSelected)"
        time.text = "0 hours, \(timeSelected) min"
        minTimer.text = "\(timeSelected) minute timer set"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        
        workUntil.text = "Work until: \(formatter.string(from: getDate(min:timeSelected)))"
        
        actions.append("\(formatter.string(from: getDate(min:0))) - \(formatter.string(from: getDate(min:timeSelected)))... \(timeSelected) minute timer")
        tableView.reloadData()
        
        let dialogConfirm = UIAlertController(title: "\(timeSelected) min countdown", message: "After \(timeSelected) Minutes, you'll be notified.\nTurn your ringer on", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        dialogConfirm.addAction(yes)
        present(dialogConfirm, animated: true, completion: nil)
        
        var temp = timeSelected * 60
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if temp > 0{
                temp -= 1
            }
            else{
                self.totalTime.text = "Total Time:"
                self.time.text = "0 hours, 0 min"
                self.minTimer.text = ""
                self.workUntil.text = ""
                
                Timer.invalidate()

                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = "Great job"
                content.body = "You can take a break now"
                content.sound = .default
                content.userInfo = ["value": "Data with local notification"]
                let fireDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: Date().addingTimeInterval(2))
                let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)
                let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: trigger)
                center.add(request) { (error) in
                if error != nil {
                print("Error = \(error?.localizedDescription ?? "error local notification")")
                    }
                }
                
                
            }
        }
        
    }
    
    func getDate(min: Int) -> Date{
        return Date().addingTimeInterval(Double(min) * 60.0)
    }
    
    
    @IBAction func showList(_ sender: UIButton) {
        hiddinViews(hiddin: true)
    }
    
    
    @IBAction func addNewTimer(_ sender: Any) {
        hiddinViews(hiddin: false)
        let dialogConfirm = UIAlertController(title: "Are you sure it's a new day?", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let yes = UIAlertAction(title: "New Day", style: .default, handler: { [self] (action) -> Void in
            totalTime.text = "Total Time:"
            time.text = "0 hours, 0 min"
            minTimer.text = ""
            workUntil.text = ""
            actions.removeAll()
            tableView.reloadData()
        })
        yes.setValue(UIColor.red, forKey: "titleTextColor")
        
        dialogConfirm.addAction(cancel)
        dialogConfirm.addAction(yes)
        present(dialogConfirm, animated: true, completion: nil)
    }
    
    
    @IBAction func restartTimer(_ sender: UIButton) {
        if tableView.isHidden == true && totalTime.text != "Total Time:"{
            let dialogConfirm = UIAlertController(title: "Cancel current timer?", message: "", preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { [self] (action) -> Void in
                totalTime.text = "Total Time:"
                time.text = "0 hours, 0 min"
                minTimer.text = ""
                workUntil.text = ""
                actions.append("CANCELED")
                tableView.reloadData()
            })
            yes.setValue(UIColor.red, forKey: "titleTextColor")
            
            dialogConfirm.addAction(cancel)
            dialogConfirm.addAction(yes)
            present(dialogConfirm, animated: true, completion: nil)
        }
        else{
            hiddinViews(hiddin: false)
        }
    }
}



extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        idx = row
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: minutes[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
    
    
}


extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
        
        cell.textLabel?.text = actions[indexPath.row]
        cell.textLabel?.textColor = UIColor.green
        
        return cell
    }
}
