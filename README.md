# ism-catcher
Munin plugin and other stuff for [rtl_433][1].

```
Program to parse the output of rtl_433.
It's designed to work as Munin plugin.

Usage: ism-catcher [--config=<INI>] --live
       Parse JSON from STDIN, one dataset per line!

Usage: ism-catcher [--config=<INI>] --dump=<ID>
       Dump packets of binary database <ID>.

Usage: ism-catcher [--config=<INI>] --watch=[<ID>, ...]
       Follow mode for single or multiple <ID>'s.

Usage: ism-catcher [--config=<INI>] [{autoconf|config}]
       Execute Munin plugin with optional arguments.

=========================
 Supported ENV variables 
=========================

 * hostname = virtual hostname for munin
 * ini_file = path to configuration file
```


## Hardware Requirements
* 24/7 running GNU/Linux system with USB port
* DVB-T dongle with [compatible RTL2832(U)][2] chipset
* Compatible wireless sensor (e.g. `THN128` or `THR128`)


## Software Requirements
* Munin master/node setup (+ Webserver for Munin output)
* [rtl_433][1] installation (and JSON-enabled device)
* PHP ≥ 5.5 (with JSON support)


## Data Aggregation
See: `other-scripts/run.sh` & `other-scripts/legacy/rtl_433.sh`

Examples for multiple (split or aggregated) graphs are available at the [wiki](https://github.com/froonix/ism-catcher/wiki).


## Plugin Installation
```bash
# Setup INI file...
cp -vn config/sample.ini ~/.ism.ini
editor ~/.ism.ini

# Setup plugin configuration...
cp -vn plugin-conf.d/ism /etc/munin/plugin-conf.d/
editor /etc/munin/plugin-conf.d/ism

# Enable plugin...
ln -s /full/path/to/ism-catcher /etc/munin/plugins/ism

# Test plugin...
munin-run ism config
munin-run ism

# Restart daemon...
systemctl restart --no-block munin-node
```


[1]: https://github.com/merbanan/rtl_433
[2]: http://amzn.to/2qIxh9n
