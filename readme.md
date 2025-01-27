# 🚀 LNCHR

Heavily inspired by [plul's AutoHotKey Launcher](https://github.com/plul/Public-AutoHotKey-Scripts)
and [PowerToys Run](https://learn.microsoft.com/en-us/windows/powertoys/run); this is my version of a quick launcher, compatible with AHK v2.

## The gist
Re-map `CapsLock` to open a GUI with a single textbox that runs shortcuts mapped to text that you type in. A semantic way of activating shortcuts, opening files or folders, or searching the net (who has the time to remember a million`CTRL+WIN+XYZs`? I'd rather spend that time coding!). 
You have the power to create shortcuts as desired, for example: set `pai` to MS Paint, `scr` to run an arbitrary script, or `con` to press `WIN+K` 'cause you can't remember the key-press.


## For your consideration
Unfortunately I don't have the time to well-document this. I think the code is somewhat approachable, though. 
If you want to re-map double pressing of `CapsLock`, it should be self-explanatory, for example.
All I ask in return for your use of this script is that you share any ideas that you have (or have already implemented) 🙂.



## How-to
* Run `LNCHR-Main.ahk`
* Press `CapsLock` to activate.
* Type in your command (no need to hit `Enter`)
* Some commands put the GUI in `query` mode, where you can enter additional text (pressing `Enter` is then required to submit). For example, to search Google or Spotify, first type `g␣`, followed by the search words of your choice with an `Enter`.
* Double-press `CapsLock` to activate a function of your choice (I prefer to map this to a key-press that opens PowerToys Run)
* `Escape` to exit from any state and close the GUI
* Use `(Ctrl|Shift|Alt)+CapsLock` to toggle Caps Lock instead
* While in the GUI, remap keys like `Tab` or `Win` for other shortcuts (eg. I map `Win` to open iPython terminal)

### Query
* The GUI has essentially two on-sates. One is `main`, where commands are typed without pressing `Enter`. The other is `query`, where the submitted text is pushed a pre-defined function of your choosing
* Entered text in the query mode is remembered and stored in `LNCHR-Memory.ini`, and can be browsed through the up and down arrow keys, or is auto-completed
* If you want to delete the memory for a query type, go to that query, type and submit `clr`

## Some features
* Built-in Calculator that uses [mathjs](https://mathjs.org/docs/expressions/parsing.html), with memory and programmable functions (stored in `LNCHR-CalcEqns.txt`)
* Quickly run commands with simple text replacements (eg. Google Search, Everything Search)
* Outlook search
* `LNCHR-CommandsGeneator.xlsm`: a Microsoft Excel macro-enabled spreadsheet that is used to generate the `LNCHR-Commands.ahk`  file an  a `HELP-Commands.txt` file for  quick-help and tooltip suggestions. If you will not be using this tool, I recommend setting
  `lngui_props.show_commands_tips := False` in `LNCHR-Main.ahk`. See the Help tab on the Excel file for guidance.
* Note: the briefcase icon is there because I have a flag that signals if I am
using my work or home computer. You can try to leverage this for an independent instance on a remote desktop, for example, or make computer-specific commands.





## Examples

Open my documents with `doc`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Doc.gif)

Open MS Paint with `pai`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Paint.gif)

Enable calculator mode with `c␣`. Or press `↑` or `↓` to navigate through calculator history. 
Hot tip: you can perform array math: `[1,2,3]^2`. You can store expressions like `phi = 1.618` and functions like `E(m) = m*(3e8)^2`
Type `?` and hit enter to open and edit your saved expressions, and `mem` to view the memory.


![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Calc.gif)


Search Outlook with `o␣`. Put an `!` in the query as a shortcut to `hasattachments:yes`. Notice the hints and auto-complete.

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Outlook.gif)

Compose an e-mail with `com`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Compose.gif)

Manage your commands with the provided Excel file. Mapped to `a xl`. Open this file, enable macros, and hit `ctrl+l` here
to generate `LNCHR-Commands.ahk` There are different types of commands which make templating the code much easier.
See the Help tab for more details.

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/XL.png)

