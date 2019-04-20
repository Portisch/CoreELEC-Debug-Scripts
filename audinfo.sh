#!/bin/bash
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
#
# Collect amlogic display information
#
#####################################################
#
# Comand Line Arguments
# -l = Show local only
# -r = Remove stuff that is redundent between debug scripts, and show local only
#
#####################################################

OUTPUTFILE="/storage/audinfo.txt"

fancycat()
{
# $1 = file $2 = message if file not found
    printf "------------ $1 ------------" >> $OUTPUTFILE
    if [ -f $1 ]; then
        printf "\n" >> $OUTPUTFILE
        cat $1 | tr '\000' '\n' >> $OUTPUTFILE
    else
        printf " $2\n" >> $OUTPUTFILE
    fi

}

fancychk()
{
   printf "------------ $1 ------------" >> $OUTPUTFILE
    if [ -f $1 ]; then
        printf " Set by user!\n" >> $OUTPUTFILE
    else
        printf " Unset by user!\n" >> $OUTPUTFILE
    fi

}

fancycatdir()
{
if [ -d $1 ]; then
    printf "------------ $1 ------------\n" >> $OUTPUTFILE
    for filename in $1/$2
    do
        [ -e $filename ] || continue
        if [ -f $filename ]; then
            fancycat $filename
        fi
    done
else
    printf " Directory Missing!\n"
fi

}


printf "CoreELEC Audio Information...\n\n" > $OUTPUTFILE

if [ "$1" != "-r" ]; then 
    fancycat "/etc/os-release" "Missing!"
    fancycat "/proc/device-tree/coreelec-dt-id" "Missing!"
    fancycat "/proc/device-tree/le-dt-id" "Missing!"
    fancycat "/proc/cmdline" "Missing!"
fi
fancycat "/sys/devices/virtual/amhdmitx/amhdmitx0/edid_parsing" "Missing!"
fancycat "/sys/devices/virtual/amhdmitx/amhdmitx0/rawedid" "Missing!"
fancycat "/sys/devices/virtual/amhdmitx/amhdmitx0/config" "Missing!"
fancycat "/sys/devices/virtual/amhdmitx/amhdmitx0/aud_cap" "Missing!"

    printf "------------ /sys/class/sound ------------" >> $OUTPUTFILE
if [ -d /sys/class/sound ]; then
    for soundcard in `ls -d /sys/class/sound/card*`
        do
            if [ -f $soundcard'/id' ]; then
                printf "\n" >> $OUTPUTFILE
                cat $soundcard'/id' >> $OUTPUTFILE
                for subsystem in `ls -d $soundcard'/subsystem/'*`
                    do
                        printf "$subsystem" | awk -F'/' '{print "|-"$NF}' >> $OUTPUTFILE
                    done
            fi
        done
else
    printf " Missing!\n" >> $OUTPUTFILE
fi
    printf "------------ kodi audio settings ------------" >> $OUTPUTFILE
if [ -f /storage/.kodi/userdata/guisettings.xml ]; then
    printf "\n" >> $OUTPUTFILE
    for tag in "accessibility.audiohearing" \
               "accessibility.audiovisual" \
               "accessibility.subhearing" \
               "audiooutput.ac3passthrough" \
               "audiooutput.ac3transcode" \
               "audiooutput.atempothreshold" \
               "audiooutput.audiodevice" \
               "audiooutput.boostcenter" \
               "audiooutput.channels" \
               "audiooutput.config" \
               "audiooutput.dtshdpassthrough" \
               "audiooutput.dtspassthrough" \
               "audiooutput.eac3passthrough" \
               "audiooutput.guisoundmode" \
               "audiooutput.maintainoriginalvolume" \
               "audiooutput.passthrough" \
               "audiooutput.passthroughdevice" \
               "audiooutput.processquality" \
               "audiooutput.samplerate" \
               "audiooutput.audiooutput.stereoupmix" \
               "audiooutput.audiooutput.streamnoise" \
               "audiooutput.audiooutput.streamsilence" \
               "audiooutput.truehdpassthrough" \
               "audiooutput.volumesteps" \
               "musicplayer.replaygainavoidclipping" \
               "musicplayer.replaygainnogainpreamp" \
               "musicplayer.replaygainpreamp" \
               "musicplayer.replaygaintype" \
               "musicplayer.seekdelay" \
               "musicplayer.seeksteps"
    do
        printf "$tag: " >> $OUTPUTFILE
        value=$(cat /storage/.kodi/userdata/guisettings.xml |grep "\"$tag\"" |grep -o '>.*<' |sed -E 's/[<>]//g')
        [ -n "$value" ] && printf "$value" >> $OUTPUTFILE
        printf "\n" >> $OUTPUTFILE
    done
    printf "mute: " >> $OUTPUTFILE
    value=$(cat /storage/.kodi/userdata/guisettings.xml |awk -F '[<>]' '/mute/ {print $3}')
    [ -n "$value" ] && printf "$value" >> $OUTPUTFILE
    printf "\n" >> $OUTPUTFILE
    printf "volumelevel: " >> $OUTPUTFILE
    value=$(cat /storage/.kodi/userdata/guisettings.xml |awk -F '[<>]' '/fvolumelevel/ {print $3}')
    [ -n "$value" ] && printf "$value" >> $OUTPUTFILE
    printf "\n" >> $OUTPUTFILE
else
    printf " Missing!\n" >> $OUTPUTFILE
fi

fancycat "/storage/.config/sound.conf" "Unset by user!"
fancycat "/storage/.config/asound.conf" "Unset by user!"
fancycatdir "/storage/.config/pulse-daemon.conf.d" "*.conf"

if [ "$1" != "-r" ]; then 
    fancycat "/storage/.config/autostart.sh" "Unset by user!"
fi

if [ "$1" = "-l" ] || [ "$1" = "-r" ]; then                                                                   
  cat $OUTPUTFILE                                                       
else                              
  paste $OUTPUTFILE                                                                
fi      