# ism-catcher
Munin plugin and other stuff for [rtl_433][1].


## Hardware Requirements
* 24/7 running GNU/Linux system with USB port
* DVB-T dongle with [compatible RTL2832(U)][2] chipset
* Compatible wireless sensor (e.g. `THN128` or `THR128`)


## Software Requirements
* Munin master/node setup (+ Webserver for Munin output)
* [rtl_433][1] installation (and JSON-enabled device)


## Data Aggregation
See: `other-scripts/run.sh` and `other-scripts/legacy/rtl_433.sh`


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
service munin-node restart
```


[1]: https://github.com/merbanan/rtl_433
[2]: http://amzn.to/2qIxh9n
