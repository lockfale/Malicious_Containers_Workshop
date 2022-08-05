# Cheatsheet
**This is an accompanying file with the lab instructions and commands to help those especially new to linux/docker/kubernetes.**

**If viewing on GitHub, you can navigate using the table of contents button in the top left next to the line count.**

## Using Vi - useful shortcuts for the lab. 

Arrow ←↑↓→ keys to navigate cursor
`i` to enter instert mode and edit contents.
When you're in insert mode, you'll see in the bottom left hand corner that this is happening: 

![using_vi](https://user-images.githubusercontent.com/32903188/182468365-5841a2aa-3819-4089-920f-16db197679e9.png)


`[esc]` to exit insert mode once changes are made. 

`u` outside insert mode to undo a change. 

`dd` to remove a line outside of insert mode.

`:` to bring up the vi command line outside of insert mode. 

`:wq` to save and quit. 

`:q!` to exit without changes. 

## Troubleshooting - list of error messages and what to do:

**none of the commands work without sudo**

`sudo usermod -aG docker $USER
` 

`chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
` 


**kubectl commands don't work** 

Running a command with kubectl, and you see this: 
“the connection to the server localhost:8080 was refused - did you specify the right host or port?”

Your kubeconfig has been blown away. 

` kind get kubeconfig --name lab > .kube/config  
` 



