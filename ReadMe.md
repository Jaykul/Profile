## This is my profile.

You'll see here my profile.ps1 script, along with a module which contains most of the logic.

Of particular interest is the Set-HostColor function which includes configuration for my prompt and PSGit settings...

Feel free to ask for explanation of anything you want to know.

### This module is not published to the PowerShell gallery

If you really want a copy of it, you can use the [Install-Module.ps1](https://github.com/Jaykul/Profile/blob/master/Install-Module.ps1) to install it on your box:

```posh
iex (irm https://github.com/Jaykul/Profile/raw/master/Install-Module.ps1)
```
Or you can just install all the required modules, and run `Set-PowerLinePrompt`:
```posh
Install-Module Environment, Configuration, PSGit, PowerLine, DefaultParameter
```
