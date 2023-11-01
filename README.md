cinna(mon)
======

\> about cinna
---------------

<sup><sub>(the name is TOTALLY not 'cinna' because of sanrio's cinnamoroll just uh shhhhhh)</sub></sup>

cinna is a package manager created by none other than I for simplifying the installation and management of custom programs.

[\> repo](https://cinna.pixspla.net/repo)

\> installation
---------------

after downloading the repository via Git or GitHub:

in your terminal, navigate to the directory where the files of the repository are located.

run the following command:

``` sh
    $ sudo make install
```

after that, check if cinna is fully installed by running:
```sh
    $ cinna --version
```
you can then use cinna by running:
```sh
    $ cinna
      or
    $ cinna --help
```
\> usage
--------
this is outdated, so to see a list of commands, run:
```sh
    $ cinna --help
```
### $ cinna get

this is the main command for installing packages.
```sh
    $ cinna get [name]
```
### $ cinna remove

this command will let you remove any package you have installed.
```sh
    cinna remove [name]
```
### $ cinna upgrade

this command will uninstall and reinstall any package, to get the latest version.
```sh
    cinna upgrade [name]
```
### $ cinna info

this command will display the info of any package on the repo.
```sh
    cinna info [name]
```
### $ cinna update

this command will simply update cinna.
```sh
    cinna update
```
### $ cinna --help, -h

this command will display a list of commands and what they do.
```sh
    $ cinna --help
      or
    $ cinna -h
```
### $ cinna --version, -v

this command will show you cinna's version.
```sh
    $ cinna --version
      or
    $ cinna -v
```
