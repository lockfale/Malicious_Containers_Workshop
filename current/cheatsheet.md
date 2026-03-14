# Cheatsheet
**This is an accompanying file with the lab instructions and commands to help those especially new to linux/docker/kubernetes.**

**If viewing on GitHub, you can navigate using the table of contents button in the top left next to the line count.**

## Using Vi - useful shortcuts for the lab.

Arrow keys to navigate cursor

`i` to enter insert mode and edit contents.
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

```
sudo usermod -aG docker $USER
```

```
chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

**i'm stuck in my container and i can't control+c exit**

- Open a new terminal window
- `docker container ls`
- Find the stuck container
- `docker stop $containerID` # just the first couple of characters will do, ie `docker stop ac29`

**kubectl commands don't work**

Running a command with kubectl, and you see this:
"the connection to the server localhost:8080 was refused - did you specify the right host or port?"

Your kubeconfig has been blown away.

```
kind get kubeconfig --name lab > .kube/config
```

or

```
kubectl config use-context kind-lab
```

**HTTP endpoint (Pipedream) isn't receiving requests**

- Make sure you copied the correct endpoint URL from Pipedream (not the dashboard URL)
- The URL should look like `https://eo*.m.pipedream.net`
- Verify the URL is set correctly in your Dockerfile's `ENV URL` line

**`ESC` Keymapping to escape vim in the google console web browser is not working**

Map the escape key to another key combination
i.e
`:imap jj <ESC`

**Ngrok OAuth issues**

Use Basic Authentication instead of OAuth
```
#Example of basic auth
ngrok http $WORKER1:31000 --basic-auth="frank:password123"
```

Specify your own username and password with a colon between in the `<user>:<password>` format in the basic-auth flag above.

## Supply Chain Tools Quick Reference

**cosign** - Image signing and verification
```
# Generate key pair
cosign generate-key-pair

# Sign an image (requires push access to registry)
cosign sign --key cosign.key <image>

# Verify an image signature
cosign verify --key cosign.pub <image>
```

**crane** - Container registry interactions
```
# View image manifest
crane manifest <image> | jq

# List tags
crane ls <repository>

# Get image digest (immutable reference)
crane digest <image>

# Export image filesystem
crane export <image> output.tar
```

**syft** - SBOM generation
```
# Generate SBOM for an image
syft <image>

# Output as SPDX JSON
syft <image> -o spdx-json

# Output as CycloneDX
syft <image> -o cyclonedx-json
```

**grype** - Vulnerability scanning
```
# Scan an image
grype <image>

# Scan with SBOM input
grype sbom:sbom.json

# Fail on critical vulns (useful in CI)
grype <image> --fail-on critical

# Only show fixable vulns
grype <image> --only-fixed
```

## Runtime Security Tools Quick Reference

**Tracee**
```
# Check Tracee pods
kubectl get pods -n tracee-system

# View Tracee events
kubectl logs -n tracee-system -l app.kubernetes.io/name=tracee --tail=50

# Run standalone Docker Tracee
docker run --name tracee -d --rm --pid=host --cgroupns=host --privileged \
  -v /etc/os-release:/etc/os-release-host:ro \
  -e LIBBPFGO_OSRELEASE_FILE=/etc/os-release-host \
  aquasec/tracee:latest
```

**Falco**
```
# Check Falco pods
kubectl get pods -n falco-system

# View Falco alerts
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --tail=50

# Access Falcosidekick UI
kubectl port-forward svc/falco-falcosidekick-ui -n falco-system 2802:2802
```

**Tetragon**
```
# Check Tetragon pods
kubectl get pods -n tetragon

# View Tetragon events
kubectl logs -n tetragon -l app.kubernetes.io/name=tetragon -c export-stdout --tail=50

# List TracingPolicies
kubectl get tracingpolicies
```

## Grafana Loki Queries

**Tracee events:**
```
{namespace="tracee-system"} |= `matchedPolicies` != `sshd` | json | line_format "{{.log}}"
```

**Falco events:**
```
{namespace="falco-system"} | json | line_format "{{.log}}"
```

**Tetragon events:**
```
{namespace="tetragon"} | json | line_format "{{.log}}"
```

## Version Reference

| Component | Version |
|-----------|---------|
| Kubernetes | v1.31.4 |
| kind | v0.27.0 |
| Helm | v3.16.4 |
| kubectl | v1.31.4 |
| cosign | v2.4.1 |
| crane | v0.20.2 |
| syft | v1.18.1 |
| grype | v0.85.0 |
| Tracee | 0.24.0 |
