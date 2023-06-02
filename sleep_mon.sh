#!/bin/bash

get_min=$(who -b | awk '{split($4, time, ":"); print time[2]%10}')

sleep ${get_min}m
