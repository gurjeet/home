#!/usr/bin/osascript
on run argv

	(*
	If first parameter not provided, default to "Evening Tabs" since those have
	the least amount of tabs and hence will cause the least resource cnsumption if
	this script is executed by accident.
	*)

	if argv is not {} then
		set groupName to (item 1 of argv)
	else
		set groupName to "Evening"
	end if

	set whichTabs to groupName

	tell application "System Events" to tell process "Firefox"
		# Create a new window
		click menu item "New Window" of menu 1 of menu bar item "File" of menu bar 1
		# Open appropriate group of bookmarks
		click menu item "Open All in Tabs" of menu 1 of menu item (whichTabs & " Tabs") of menu 1 of menu bar item "Bookmarks" of menu bar 1
	end tell

	activate application "Firefox"
	# Switch to the first tab of the new window
	tell application "System Events" to keystroke "{" using {command down, shift down} -- command-shift-{
	# Close the first tab of the window since it's just blank/default
	tell application "System Events" to keystroke "w" using {command down} -- command-w

end run

