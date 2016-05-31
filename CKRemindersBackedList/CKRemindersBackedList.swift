//
//  CKRemindersBackedList.swift
//
//  Created by Christian Klaproth on 31.05.16.
//  Copyright © 2016 Christian Klaproth. All rights reserved.
//

import UIKit
import EventKit

public class CKRemindersBackedList: NSObject {

    let eventStore: EKEventStore
    var eventCalendar: EKCalendar!
    var reminders = Array<EKReminder>()
    
    private override init() {

        self.eventStore = EKEventStore()
        
        super.init()
        
        self.eventStore.requestAccessToEntityType(EKEntityType.Reminder) { (granted, error) in
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
        
        let reminderLists = self.eventStore.calendarsForEntityType(EKEntityType.Reminder).filter { (cal) -> Bool in
            return cal.title == name
        }
        
        if let calendar = reminderLists.first {
            // existing calendar found
            self.eventCalendar = calendar
            print("Using existing calendar.")
        } else {
            // create new calendar
            self.eventCalendar = EKCalendar(forEntityType: EKEntityType.Reminder, eventStore: self.eventStore)
            self.eventCalendar.title = name
            if let calendarColor = color {
                self.eventCalendar.CGColor = calendarColor.CGColor
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
    
    public func containsEntry(key: String) -> Bool {
        if let _ = getEntryForKey(key) {
            return true
        }
        return false
    }

    public func addEntry(key: String, withNotes notes: String?) {
        
        let reminder = EKReminder(eventStore: self.eventStore)
        reminder.title = key
        reminder.notes = notes
        reminder.calendar = self.eventCalendar
        
        let today = NSDate()
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        reminder.dueDateComponents = gregorian?.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: today)
        
        do {
            try self.eventStore.saveReminder(reminder, commit: true)
            self.reminders.append(reminder)
        } catch {
            print("Reminder could not be saved to EventStore.")
        }
    }
    
    public func removeEntry(key: String) {
        
        if let reminder = getEntryForKey(key) {
        
            do {
                try self.eventStore.removeReminder(reminder, commit: true)
                if let index = self.reminders.indexOf(reminder) {
                    self.reminders.removeAtIndex(index)
                }
            } catch {
                print("Reminder could not be deleted from EventStore.")
            }
        } else {
            print("Reminder '\(key)' not found.")
        }
    }
    
    func getEntryForKey(key: String) -> EKReminder? {
        return self.reminders.filter { (reminder) -> Bool in
            return reminder.title == key && !reminder.completed
        }.first
    }
    
    func updateEntries() {
        let predicate = self.eventStore.predicateForRemindersInCalendars([self.eventCalendar])
        self.eventStore.fetchRemindersMatchingPredicate(predicate) { (result) in
            if let reminderList = result {
                self.reminders.removeAll()
                self.reminders.appendContentsOf(reminderList)
            }
        }
    }
}
