Boxed environment
=================

This repository provides a boxed environment with:

 -  a unique dBus session for the boxed environment
 -  a systemd instance for the boxed envrionment

Usage
=====

Just run the `box.sh` script in front of the command you want to run and the
command is executed in the boxed environment. The environment is rooted at the
location where the script is. The following environment variables are modified:

 -  `XDG_CONFIG_HOME`:   to the `config` directory
 -  `XDG_DATA_HOME`:     to the `data` directory
 -  `SYSTEMD_UNIT_PATH`: to the `units` directory

Plugins
=======

Each directory in the |plugins` directory corresponds to a plugin. Each plugin
can have a `units` directory. This directory is appended to the end of
`SYSTEMD_UNIT_PATH`.


