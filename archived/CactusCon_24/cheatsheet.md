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

**i'm stuck in my container and i can't control+c exit** 
 

- Open a new terminal window 
- `docker container ls` 

- find the stuck container 

- `docker stop $containerID` # just the first couple of characters will do, ie `docker stop ac29` 
 

**kubectl commands don't work** 

Running a command with kubectl, and you see this: 
“the connection to the server localhost:8080 was refused - did you specify the right host or port?”

Your kubeconfig has been blown away. 

` kind get kubeconfig --name lab > .kube/config  
` 

or 

`kubectl config use-context kind-lab`

**POSTING to requestbin.com isn't working** 
 
Did you paste a pipedream link from your unique page, or a requestbin link? 
use this one: 
<img width="575" alt="image" src="https://user-images.githubusercontent.com/32903188/184508462-23c14724-231d-4391-b971-e78af5450573.png">


**`ESC` Keymapping to escape vim in the google console web browser is not working** 

Map the escape key to another key combination 
i.e
`:imap jj <ESC` 

** Ngrok Oauth issues **

Use Basic Authentication instead of OAuth
```
#Example of basic auth
ngrok http $WORKER1:31000 --basic-auth="frank:password123"
```

Specify your own username and password with a colon between in the `<user>:<password>` format in the basic-auth flag above.