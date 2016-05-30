# CKRemindersBackedList
Leverage the power of iOS Reminders within your app.

## Introduction
 Assuming your users are viewing or maintaining some sort of data entries and they come to the point where they think: *"Damn, I need to ask a colleague about that entry, but he's currently in a meeting. If only I had a simple way to flag this entry without interrupting my current workflow."* - *"No problem!"*, the expert iOS developer thinks. *"Let's introduce some data structure within the NSUserDefaults... or wait... let's set up a CoreData stack to store the flags. And set up some local notifications to remind the user. Oh and some UI for maintaining the list of flags, mark them as done, adding custom notes and so on. Uh, erm... and some syncing between devices."* Wait a minute! Are we just reimplementing the Reminders app? Why not use it (in)directly?! `CKRemindersBackedList` helps you doing exactly this.
 
## Advantages
* Adding flags or reminders won't close your app. Your user is not distracted from his current workflow.
* Your user will most likely be already familiar with the Reminders app as it is shipped with iOS.

## Disadvantages
* `CKReminderBackedList` uses the EventKit to access the reminders of the current user. To do so, we need to ask the user for the permission to access his calendar. If your user does not trust you and will not permit access, this solution won't work.
