//
//  ViewController.swift
//  RemindersBackedListDemo
//
//  Created by Christian Klaproth on 31.05.16.
//  Copyright © 2016 Christian Klaproth. All rights reserved.
//

import UIKit
import CKRemindersBackedList

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct Entry: CKReminderIdentifiable {
        let title: String
        let detail: String
        
        func identificationForReminder() -> String {
            return title
        }
    }
    
    var entries = Array<Entry>()
    
    let remindersBackedList = CKRemindersBackedList(name: "RemindersBackedListDemo", color: UIColor.blue)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        entries.append(Entry(title: "Casual Coder", detail: "'Now this GitHub project looks interesting'."))
        entries.append(Entry(title: "Ninja Coder", detail: "You never knew who geniusly coded your app..."))
        entries.append(Entry(title: "Dangerous Coder", detail: "Copy & Paste from StackOverflow. Works!"))
        entries.append(Entry(title: "Empathic Coder", detail: "Feels what the user feels."))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let entry = entries[(indexPath as NSIndexPath).row]
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let detailLabel = cell.viewWithTag(2) as! UILabel
        
        titleLabel.text = entry.title
        detailLabel.text = entry.detail
        
        let markButton = cell.viewWithTag(3) as! UIButton
        markButton.accessibilityHint = "\((indexPath as NSIndexPath).row)"
        markButton.addTarget(self, action: #selector(ViewController.toggleMarkButton(_:)), for: UIControlEvents.touchUpInside)
        if (self.remindersBackedList.containsEntry(entry)) {
            markButton.setTitle("Unmark", for: UIControlState())
        } else {
            markButton.setTitle("Mark", for: UIControlState())
        }
        
        return cell
    }
    
    func toggleMarkButton(_ sender: UIButton) {
        let index = Int(sender.accessibilityHint!)!
        
        print("Toggle Button pressed at index \(index).")
        
        let entry = entries[index]
        
        if (self.remindersBackedList.containsEntry(entry)) {
            self.remindersBackedList.removeEntry(entry)
        } else {
            self.remindersBackedList.addEntry(entry, withNotes: entry.detail)
        }
        
        let path = IndexPath(row: index, section: 0)
        self.tableView.reloadRows(at: [path], with: UITableViewRowAnimation.fade)
    }
}

