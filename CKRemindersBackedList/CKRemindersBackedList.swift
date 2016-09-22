//
//  CKRemindersBackedList.swift
//
//  Created by Christian Klaproth on 31.05.16.
//  Copyright © 2016 Christian Klaproth. All rights reserved.
//

import UIKit
import EventKit

public protocol CKReminderIdentifiable {
    func identificationForReminder() -> String
}

open class CKRemindersBackedList: NSObject {

    let eventStore: EKEventStore
    var eventCalendar: EKCalendar!
    var reminders = Array<EKReminder>()
    
    fileprivate override init() {

        self.eventStore = EKEventStore()
        
        super.init()
        
        self.eventStore.requestAccess(to: EKEntityType.reminder) { (granted, error) in
            if (granted) {
                print("Access granted for calendar.")
            } else {
                print("Access denied for calendar.")
            }
        }
    }
    
    /**
     * Creates a new Reminders backed list.
     * @param name will be used as the calendar's title
     * @param color (optional) will be used as the calendar's color
     */
    required public convenience init(name: String, color: UIColor?) {

        self.init()
        
        let reminderLists = self.eventStore.calendars(for: EKEntityType.reminder).filter { (cal) -> Bool in
            return cal.title == name
        }
        
        if let calendar = reminderLists.first {
            // existing calendar found
            self.eventCalendar = calendar
            print("Using existing calendar.")
        } else {
            // create new calendar
            self.eventCalendar = EKCalendar(for: EKEntityType.reminder, eventStore: self.eventStore)
            self.eventCalendar.title = name
            if let calendarColor = color {
                self.eventCalendar.cgColor = calendarColor.cgColor
            }
            self.eventCalendar.source = self.eventStore.defaultCalendarForNewReminders().source
            
            do {
                try self.eventStore.saveCalendar(self.eventCalendar, commit: true)
                print("Created new calendar.")
            } catch {
                print("Calendar could not be saved to EventStore.")
            }
        }
        
        self.updateEntries()

    }
    
    open func accessGranted() -> Bool {

        return true
    }
    
    open func containsEntry(_ entry: CKReminderIdentifiable) -> Bool {
        
        return self.containsEntry(entry.identificationForReminder())
    }
    
    open func containsEntry(_ key: String) -> Bool {
        
        if let _ = getEntryForKey(key) {
            return true
        }
        return false
    }

    open func addEntry(_ entry: CKReminderIdentifiable, withNotes: String) {
        
        self.addEntry(entry.identificationForReminder(), withNotes: withNotes)
    }
    
    open func addEntry(_ key: String, withNotes notes: String?) {
        
        let reminder = EKReminder(eventStore: self.eventStore)
        reminder.title = key
        reminder.notes = notes
        reminder.calendar = self.eventCalendar
        
        let today = Date()
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        reminder.dueDateComponents = (gregorian as NSCalendar?)?.components([NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year], from: today)
        
        do {
            try self.eventStore.save(reminder, commit: true)
            self.reminders.append(reminder)
        } catch let error as NSError {
            print("Reminder could not be saved to EventStore. (Reason: \(error.localizedDescription))")
        }
    }
    
    open func removeEntry(_ entry: CKReminderIdentifiable) {
        
        self.removeEntry(entry.identificationForReminder())
    }
    
    open func removeEntry(_ key: String) {
        
        if let reminder = getEntryForKey(key) {
        
            do {
                try self.eventStore.remove(reminder, commit: true)
                if let index = self.reminders.index(of: reminder) {
                    self.reminders.remove(at: index)
                }
            } catch let error as NSError {
                print("Reminder could not be deleted from EventStore. (Reason: \(error.localizedDescription))")
            }
        } else {
            print("Reminder '\(key)' not found.")
        }
    }
    
    func getEntryForKey(_ key: String) -> EKReminder? {
        return self.reminders.filter { (reminder) -> Bool in
            return reminder.title == key && !reminder.isCompleted
        }.first
    }
    
    func updateEntries() {
        let predicate = self.eventStore.predicateForReminders(in: [self.eventCalendar])
        self.eventStore.fetchReminders(matching: predicate) { (result) in
            if let reminderList = result {
                self.reminders.removeAll()
                self.reminders.append(contentsOf: reminderList)
            }
        }
    }
}
