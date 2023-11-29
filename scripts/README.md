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
will output memory and CPU utilization for pods in kube-system namespace

You also can get such statistics for arbitrary namespace using the next command variant:
```
kubectl kubeplugin pod <name-space>
```
