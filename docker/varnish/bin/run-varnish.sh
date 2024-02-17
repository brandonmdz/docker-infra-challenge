#!/bin/bash

exec varnishd -F -a :6081 -T localhost:6082 -f $VARNISH_CONFIG -s $VARNISH_STORAGE