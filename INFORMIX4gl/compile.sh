#!/bin/bash
# Compilation script for Informix 4GL Music Organizer

echo "Compiling Informix 4GL Music Organizer..."
echo "========================================="

# Set environment if needed (adjust paths as necessary)
# export INFORMIXDIR=/opt/informix
# export PATH=$INFORMIXDIR/bin:$PATH

# Compile form files
echo "Compiling forms..."
form4gl musiclist.per
if [ $? -ne 0 ]; then
    echo "Error compiling musiclist form"
    exit 1
fi

form4gl songdetail.per  
if [ $? -ne 0 ]; then
    echo "Error compiling songdetail form"
    exit 1
fi

# Compile 4GL program
echo "Compiling 4GL program..."
c4gl -o musicorg musicorg.4gl
if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    echo "Run with: ./musicorg"
    echo ""
    echo "Make sure the 'organiste' database exists and contains the music table."
    echo "See README.md for database setup instructions."
else
    echo "Error compiling 4GL program"
    exit 1
fi