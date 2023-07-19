# 🚀 LNCHR

Heavily inspired by [TheBestPessimist's AutoHotKey-Launcher](https://github.com/TheBestPessimist/AutoHotKey-Launcher/blob/master/README.md)
and [PowerToys Run](https://learn.microsoft.com/en-us/windows/powertoys/run), this my version of a quick launcher, compatible with AHK v2.

## The gist
Re-map CapsLock to open a GUI with a single textbox that runs shortcuts mapped to text that you type in. A semantic way of activating shortcuts (who has the time to remember a million`CTRL+WIN+XYZs`? I'd rather spend that time coding!), opening files or folders, or searching the net. 


## For your consideration
Unfortunately I don't have the time to well-document this. I think the code is somewhat approachable. 
If you want to re-map double pressing of `CapsLock`, it should be self-explanatory, for example.
All I ask in return for your use of this script is that you share any ideas that you have (or have implemented) 🙂.


## How-to
* Run `LNCHR-Main.ahk`
* Press `CapsLock` to activate.
* Type in your command (no need to hit `Enter`)
* Some commands put the GUI in 'query' mode, where you can enter additional text (`Enter` required), for example, to search Google or Spotify 
* Double-press `CapsLock` to activate a function of your choice (I map this to a key-press that opens PowerToys Run)
* `Escape` to exit from any state and close the GUI
* Use `(Ctrl|Shift|Alt)+CapsLock` to toggle Caps Lock instead
* While in the GUI, remap keys like `Tab` or `Win` for other shortcuts (eg. open iPython terminal)


## Some features
* Built-in Calculator that uses [mathjs](https://mathjs.org/docs/expressions/parsing.html), with memory and programmable functions
* Quickly run commands with simple text replacements (eg. Google Search, Everything Search)
* Outlook search
* LNCHR-CommandsGeneator.xlsm: a Microsoft Excel macro-enabled spreadsheet that is used to generate the commands file (LNCHR-Commands.ahk) and  a .txt file for  quick-help
* Note: the briefcase icon is there because I have a flag that signals if I am
using my work or home computer. You can try to leverage this for an independent instant on a remote desktop, for example.



## Examples

Open my documents with `doc`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Doc.gif)

Open MS Paint with `pai`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Paint.gif)

Enable calculator mode with `c␣`. Or press `↑` or `↓` to navigate through calculator history. 
Hot tip: you can perform array math: `[1,2,3]^2`. You can store expressions like `phi = 1.618` and functions like `E(m) = m*(3e8)^2`
Type `?` and hit enter to open and edit your saved expressions, and `mem` to view the memory.



![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Calc.gif)


Search Outlook with `o␣`. Put an `!` in the query as a shortcut to `hasattachments:yes`.

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Outlook.gif)

Compose an e-mail with `com`

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/Compose.gif)

Manage your commands with the provided Excel file. Mapped to `a xl`. Open this file, enable macros, and hit `ctrl+l` here
to generate `LNCHR-Commands.ahk` There are different types of commands (column D) which make templating the code a lot easier.
See the Help tab for more details.

![](https://github.com/kalekje/LNCHR-pub/blob/master/demo/XL.png)

