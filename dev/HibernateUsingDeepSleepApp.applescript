#!/usr/bin/osascript
(*
This script automates hibernation of macOS, provided that the
trial version of DeepSleep app is installed.
*)

# Activate the DeepSleep app
activate application "DeepSleep"

-- Click on appropriate buttons to make macOS initiate Hibernate sequence
tell application "System Events" to tell process "DeepSleep"
	click button "Try" of window 1
	click button "Hibernate" of window 1
end tell


