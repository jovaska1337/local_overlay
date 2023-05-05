#!/bin/sh

my_dir()
{
        prg="$0"
        [ ! -f "$prg" ] && prg=`which -- "$prg"`
        echo "`cd \`dirname -- "$prg"\` && pwd`"
}

sh "`my_dir`/xidlehook.sh" stop
