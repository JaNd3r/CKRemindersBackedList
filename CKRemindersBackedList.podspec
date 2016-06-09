
Pod::Spec.new do |s|

  s.name         = "CKRemindersBackedList"
  s.version      = "0.1.1"
  s.summary      = "Leverage the power of reminders within your app."

  s.description  = <<-DESC
                   CKRemindersBackedList lets you easily store simple marks like
                   favorites or reminders in the Reminders app that comes with
                   iOS.
                   DESC

  s.homepage     = "https://github.com/JaNd3r/CKRemindersBackedList"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Christian Klaproth" => "ck@cm-works.de" }
  s.social_media_url   = "http://twitter.com/JaNd3r"

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/JaNd3r/CKRemindersBackedList.git", :tag => "0.1.1" }

  s.source_files  = "CKRemindersBackedList/*.swift"

end
