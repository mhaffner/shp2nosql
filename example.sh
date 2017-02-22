#!/bin/bash
rflag=false
small_r=false
big_r=false

usage () { echo "How to use"; }

options=':ij:rRvh'
while getopts $options option
do
    case $option in
        i  ) i_func;;
        j  ) j_arg=$OPTARG;;
        r  ) rflag=true; small_r=true;;
        R  ) rflag=true; big_r=true;;
        v  ) v_func; other_func;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

shift $(($OPTIND - 1))

if ! $rflag && [[ -d $1 ]]
then
    echo "-r or -R must be included when a directory is specified" >&2
    exit 1
fi
