#!/bin/bash

echo "Fixing directory permissions..."

chmod 777 data
chmod 777 data/xml/cisco
chmod 777 data/xml/yealink
chmod 777 data/xml/cisco/directories
chmod 777 data/xml/yealink/directories

echo "Fixing file permissions..."

chmod 777 data/settings.json
chmod 777 data/xml/cisco/menu.xml
chmod 777 data/xml/yealink/menu.xml
chmod 777 data/xml/cisco/directories/*.xml
chmod 777 data/xml/yealink/directories/*.xml

echo "Done!"
