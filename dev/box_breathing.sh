#!/usr/bin/env bash

# See https://www.webmd.com/balance/what-is-box-breathing

tput_sound_command="tput bel"
backup_command="$tput_sound_command"

# Pick a few different, suitable sounds from AppleOS system files
sound_files=(/System/Library/Sounds/{Morse,Pop,Tink}.aiff)

# Array/list of all the commands
sound_commands=()

# Turn the files into commands 
for file in ${sound_files[@]}; do
    # Use afplay command to play the files; advice picked from
    # https://stackoverflow.com/a/48473111/382700
    sound_commands+=("afplay $file")
done

# If interested, we can use the system default BEL sound as one
# of the sounds, as well.
#sound_commands+=("$tput_sound_command")

# Perform these commands forever
while true; do

    for cmd in "${sound_commands[@]}"; do

        # Run the sound 4 times; the 4 edges of the box
        for ((i = 0; i < 4; ++i)); do
            echo Running $cmd;

            # Run the command in background, to prevent the
            # time/clock drift. Run the $backup_command, if the
            # primary command fails for any reason.
            $cmd || $backup_command &

            # Wait for 4 seconds; length of each edge of the box
            sleep 4;
        done
    done
done

