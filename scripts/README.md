# kubeplugin

A wrapper around the ```kubectl top``` command that makes it easier to display resource utilization statistics for pods and nodes in Kubernetes cluster.

## Installing

A plugin is a standalone executable file, with name kubectl-kubeplugin. To install a plugin, move its executable file to anywhere on your PATH or
add script's home directory to the PATH.

```
git clone git@github.com:bergshrund/kbot.git; cd kbot/scripts; export PATH=$PATH:$PWD
```
Then check plugin visibility

```
$kubectl plugin list
The following compatible plugins are available:

/home/user/kbot/scripts/kubectl-kubeplugin
```

## Running plugin

Running:
```
kubectl kubeplugin
```
will output current memory and CPU utilization for pods in kube-system namespace
```
pod     kube-system     coredns-77ccd57875-csjlk        3m      13Mi
pod     kube-system     local-path-provisioner-957fdf8bc-l27wd  1m      7Mi
pod     kube-system     metrics-server-648b5df564-z5vsv 8m      17Mi
pod     kube-system     svclb-traefik-10df67bd-wf2ch    0m      0Mi
pod     kube-system     traefik-64f55bb67d-4258d        1m      26Mi
```

You also can get such statistics for arbitrary namespace using the next command variant:
```
kubectl kubeplugin pod <name-space>
```
