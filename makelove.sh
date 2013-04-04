#!/bin/bash

rm mm.love
zip -r mm.love ./*
scp mm.love sanctuary-interactive.com:/home/steve/public_html/mm.love
echo "http://www.sanctuary-interactive.com/~steve/mm.love" | xclip -selection c
notify-send "Done"
echo "Done"
