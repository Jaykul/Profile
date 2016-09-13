## This is my profile.

You'll see here my profile.ps1 script, along with a module which contains most of the logic.

Of particular interest is the Set-HostColor function which includes configuration for my prompt and PSGit settings...

Feel free to ask for explanation of anything you want to know.

### This module is not published to the PowerShell gallery

But all of the other modules which it uses are:

```posh
Install-Module Environment, Configuration, PSGit, PowerLine, DefaultParameter
```