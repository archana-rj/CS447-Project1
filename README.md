# CS447 Project 1: Toy Keyboard

This project implements a very simple keyboard. With it, you
will be able to:

a) play notes using your computer’s keyboard
b) play a demo song
c) record your own song and play it back

## 1. The program menu

This is going to be an interactive command-line (text) program, like
lab2 (the calculator) was.

The main loop will accept these commands:

  - k - for keyboard mode (just making sounds)
  - d - for demo mode (whee)
  - r - for record mode
  - p - to play the recorded song
  - q - to quit.

Anything else should give an error message, and then ask for the
command again.

## 2. Keyboard mode and playing notes

With keyboard mode, you will be able to play your computer keyboard
like a piano.

  - If user presses one of the note keys, play a MIDI note using the
    current instrument
  - If user presses backtick ( '`' ), let them type a number in the
    range 1 to 128 to choose an instrument
  - If user presses enter ( '\n' ), exit keyboard mode

## 3. Playing a demo song

  - It will take two arguments: the address of the notes array and the 
    address of the times array
  - It will play a very common keyboard demo song
    the address of the times array.
    
## 4. Recording your own song

  ### Recording and playing the notes
  - Make two new arrays to hold the notes and times

  ### Recording the times
  - Use a syscall to measure the time at which each key is pressed. From that, calculate how long each note
    will be.
