#!/bin/bash

# Author            : Bartosz Bartczak (s188848@student.pg.edu.pl)
# Created on        : 25.04.2022
# Last Modified By  : Bartosz Bartczak (s188848@student.pg.edu.pl)
# Last Modified On  : 10.05.2022
# Version           : v0.4
#
# Description       : Program do tworzenia i odtwarzania kopii zapasowej
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Doundation for a copy)

FOLDER=""
DESTINATION=""

while getopts ":hv" opt; do
        case ${opt} in
        h )
        echo ""
        echo "Program do tworzenia kopii zapasowej"
        echo ""
        echo " - Stworz backup - tworzenie kopii zapasowej folderu wybranego przez uzytkownika w folderze docelowym"
        echo "   * 'this' (w folderze do backupu) - Getter folderu, w ktorym znajduje sie skrypt"
        echo " - Odtworz backup - odtworzenie kopii zapasowej w wybranym przez uzytkownika folderze"
        echo " - Zakoncz - zamkniecie programu"
        echo ""
        exit ;;
        v )
        echo ""
        echo "Backup commander"
        echo ""
        echo " - Author: Bartosz Bartczak"
        echo " - Version: 0.1"
        echo " - Baza: Zenity"
        echo ""
        exit ;;
        \? )
        exit ;;
        esac
    done

while true; do

    LAST_BACKUP=$(<config.txt)

    MENU_CHOICE="$(zenity --width=500 --height=300 --list --column " " --title="Backup commander" --text="Last backup date   :   $LAST_BACKUP" \
    "Stworz backup" \
    "Odtworz backup" \
    "Zaplanuj backup" \
    "Zakoncz")"

    if [[ $MENU_CHOICE == "Stworz backup" ]] ; then

        BACKUP_INFO=$(zenity --forms --title="Backup commander" --text="Podaj informacje do backupu" --separator=";" --add-entry="Katalog do backupu" --add-entry="Katalog docelowy")

        FOLDER=$(echo $BACKUP_INFO | cut -d ';' -f 1)
        DESTINATION=$(echo $BACKUP_INFO | cut -d ';' -f 2)

        if [[ $FOLDER == "this" ]] ; then
        FOLDER=$(pwd)
        fi

        if [[ $DESTINATION == "" ]] ; then
            zenity --width=300 --height=50 --error --text="Nie wybrano folderu docelowego"
        else
            DATE=$(date +%Y-%m-%d_%H-%M-%S)
            DEST_FOLER=$DESTINATION
            tar -cvf $DATE.tar -C $FOLDER .
            cp $DATE.tar $DESTINATION
            rm $DATE.tar
            zenity --info --width=300 --height=50 --text="Kopia zapasowa zostala pomyslnie utworzona"

            echo $DATE > config.txt
        fi

    fi

    if [[ $MENU_CHOICE == "Odtworz backup" ]] ; then

        FILES=$(zenity --file-selection)

        RECOVER_INFO=$(zenity --forms --title="Backup commander" --text="Please enter needed information" --separator=";" --add-entry="Katalog docelowy")

        FOLDER=$(echo $RECOVER_INFO | cut -d ';' -f 1)
        DESTINATION=$(echo $RECOVER_INFO | cut -d ';' -f 2)

        FILENAME="$(basename -- $FILES)"

        cp -i $FILES $DESTINATION
        cd $DESTINATION
        tar -xvf $FILES
        rm $FILENAME


        if [[ $DESTINATION == "" ]] ; then
            zenity --width=300 --height=50 --error --text="Nie wybrano folderu docelowego"
        else
            #revocering backup
            cp $FOLDER/* $DESTINATION
            zenity --info --width=300 --height=50 --text="Kopia zapasowa zostala pomyslnie odtworzona"

        fi

    fi

    if [[ $MENU_CHOICE == "Zaplanuj backup" ]] ; then

        PLANNED_BACKUP_INFO=$(zenity --forms --title="Backup commander" --text="Please enter needed information" --separator=";" --add-entry="Katalog do backupu" --add-entry="Katalog docelowy" --add-entry="Co ile? [sekund]" --add-entry="Ile razy?")

        FOLDER=$(echo $PLANNED_BACKUP_INFO | cut -d ';' -f 1)
        DESTINATION=$(echo $PLANNED_BACKUP_INFO | cut -d ';' -f 2)
        TIME=$(echo $PLANNED_BACKUP_INFO | cut -d ';' -f 3)
        REPEAT=$(echo $PLANNED_BACKUP_INFO | cut -d ';' -f 4)

        COUNT=0

        if [[ $FOLDER == "" ]] ; then
            zenity --width=300 --height=50 --error --text="Nie wybrano folderu bazowego"
        else

            if [[ $DESTINATION == "" ]] ; then
                zenity --width=300 --height=50 --error --text="Nie wybrano folderu docelowego"
            else

                if [[ $TIME == "" ]] ; then
                    TIME=0
                fi

                if [[ $REPEAT == "" ]] ; then
                    REPEAT=1
                fi

                zenity --info --width=300 --height=50 --text="Kopia zapasowa zostala pomyslnie zaplanowana"

                while [[ $COUNT != $REPEAT ]] ; do
                    DATE=$(date +%Y-%m-%d_%H-%M-%S)
                    sleep $TIME
                    DEST_FOLER=$DESTINATION
                    tar -cvf $DATE.tar -C $FOLDER .
                    cp $DATE.tar $DESTINATION
                    rm $DATE.tar
                    echo $DATE > config.txt
                    COUNT=$(($COUNT+1))
                done

            fi

        fi

    fi


    if [[ $MENU_CHOICE == "Zakoncz" ]] ; then
        exit
    fi

done
