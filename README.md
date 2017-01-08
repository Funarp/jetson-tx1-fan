# Jetson TX1 fan
The fan on Jetson TX1 seems not working or nvidia's default starting line is too high.

### Usage
```
$ sudo cp fan.pl /usr/local/bin/fan
$ sudo chmod +x /usr/local/bin/fan
```

Then edit `/etc/rc.local`, add those lines

```
if [ -x /usr/local/bin/fan ] ; then
    /usr/local/bin/fan
fi
```

Finally, reboot your Jetson TX1

### Details

See this blog [post](https://blog.0xbbc.com/2017/01/jetson-tx1-fan-not-working/). 
