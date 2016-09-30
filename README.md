# Cilkide package

This package is designed to help programmers using the Cilk threading library keep track of their race conditions as they are writing code in Atom. The plugin will automatically run cilksan in the background and report the results to the users, notifying them if race conditions appear.

## Setting up the package
In order to notify the package that you are writing a project with Cilk, you must place a configuration file `cilkide-conf.json` in the top-level directory of the project. You should also have a Makefile present in that directory so that the package can build the project. The configuration file should have a few settings settings:
```JSON
{
  "cilksanCommand": "Enter a Make command that will compile (with cilksan enabled) and run the executable.",

  "hostname": "Hostname for running cilk on a remote server - usually athena.dialup.mit.edu",
  "port": 22,
  "username": "Username for SSH login, usually your Athena login",
  "launchInstance": true,
  "localBaseDir": "Full directory path of the project directory on your local computer",
  "remoteBaseDir": "Full directory path of the project directory on the remote instance (ie /afs/athena.mit.edu/user/g/c/gchau/my-project)"
}
```
You can automatically generate a template configuration file in a folder by pressing "Register Cilk project" on the status bar. Once this is done, the package will periodically run cilksan on the executable generated by the Make command. The status bar icon will show the package status for the current file open.

Note: If you are using SSH (which you probably are), every time you save a file, the plugin will upload it to the remote server and try to recompile it. You can also sync local -> remote and remote -> local by going to Packages > Cilkide > Sync Project.
