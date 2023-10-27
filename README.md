  parcel is fun to say 

parcel
======

\> about parcel
---------------

parcel is a package manager created by none other than I for simplifying the installation and management of custom programs.

[\> repo](https://parcel.pixspla.net/repo)

\> installation
---------------

after downloading the repository via Git or GitHub:

in your terminal, navigate to the directory where the files of the repository are located.

run the following commands:

``` sh
    $ sudo make install
```

after that, check if parcel is fully installed by running:
```sh
    $ parcel --version
```
you can then use parcel by running:
```sh
    $ parcel
      or
    $ parcel --help
```
\> usage
--------
this is outdated, so to see a list of commands, run:
```sh
    $ parcel --help
```
### $ parcel get

this is the main command for installing packages.
```sh
    $ parcel get [name]
```
### $ parcel remove

this command will let you remove any package you have installed.
```sh
    parcel remove [name]
```
### $ parcel upgrade

this command will uninstall and reinstall any package, to get the latest version.
```sh
    parcel upgrade [name]
```
### $ parcel info

this command will display the info of any package on the repo.
```sh
    parcel info [name]
```
### $ parcel update

this command will simply update parcel.
```sh
    parcel update
```
### $ parcel --help, -h

this command will display a list of commands and what they do.
```sh
    $ parcel --help
      or
    $ parcel -h
```
### $ parcel --version, -v

this command will show you parcel's version.
```sh
    $ parcel --version
      or
    $ parcel -v
```
