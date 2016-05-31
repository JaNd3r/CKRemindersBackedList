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

    struct Entry {
        let title: String
        let detail: String
    }
    
    var entries = Array<Entry>()
    
    let remindersBackedList = CKRemindersBackedList(name: "RemindersBackedListDemo", color: UIColor.blueColor())
    
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let entry = entries[indexPath.row]
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let detailLabel = cell.viewWithTag(2) as! UILabel
        
        titleLabel.text = entry.title
        detailLabel.text = entry.detail
        
        let markButton = cell.viewWithTag(3) as! UIButton
        markButton.accessibilityHint = "\(indexPath.row)"
        markButton.addTarget(self, action: #selector(ViewController.toggleMarkButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if (self.remindersBackedList.containsEntry(entry.title)) {
            markButton.setTitle("Unmark", forState: UIControlState.Normal)
        } else {
            markButton.setTitle("Mark", forState: UIControlState.Normal)
        }
        
        return cell
    }
    
    func toggleMarkButton(sender: UIButton) {
        let index = Int(sender.accessibilityHint!)!
        
        print("Toggle Button pressed at index \(index).")
        
        let entry = entries[index]
        
        if (self.remindersBackedList.containsEntry(entry.title)) {
            self.remindersBackedList.removeEntry(entry.title)
        } else {
            self.remindersBackedList.addEntry(entry.title, withNotes: entry.detail)
        }
        
        let path = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

