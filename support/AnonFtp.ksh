#!/bin/ksh
#
# Title:        AnonFtp.ksh
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
# 
#   This is a simple shell script to fetch the tools needed
#   to build and install NcmLookups. It can be used to retreive
#   any binary file from any host via anonymous ftp.
#
#   AnonFtp.ksh host remotefile localdir
# 
# Notes:
# 
# Author:	Paul Houghton - (paul4hough@gmail.com)
# Created:	10/28/99 15:29
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    %PO%
#   Last Mod:	    %PRT%
#   Version:	    %PIV%
#   Status:	    %PS%
#
#   %PID%
# 

# set -x

cmdfile=/tmp/AnonFtp.cmd.$$

host=$1
remote_file=$2
local_dir=$3

if [ -z "$host" \
 -o -z "$remote_file" \
 -o -z "$local_dir" \
 -o ! -d "$local_dir" ] ; then
  echo "usage: $0 host remote_file local_dir"
  exit 1
fi

remote_dir=`dirname $remote_file`
remote_fn=`basename $remote_file`

if [ -n "$USER" ] ; then
  ftp_user=$USER
else
  if [ -n "$LOGIN" ] ; then
    ftp_user=$LOGIN
  else
    if [ -n "$LOGNAME" ] ; then
      ftp_user=$LOGNAME
    else
      ftp_user=`who am i | cut -d ' ' -f 1`
    fi
  fi
fi


cat << EOF > $cmdfile
open $host
user anonymous $ftp_user@aol.com
binary
cd $remote_dir
get $remote_fn
close
quit
EOF

cd $local_dir
if ftp -vn < $cmdfile ; then
  exit_code=0
else
  echo "ftp FAILED."
  cat $cmdfile
  exit_code=1
fi

if [ -f $local_dir/$remote_fn -a $exit_code = 0 ] ; then
  echo "retrieved $local_dir/$remote_fn"
else
  echo "retrieval FAILED."
  cat $cmdfile
  exit_code=1
fi  

rm $cmdfile

exit $exit_code

#
# 
#
# %PL%
#
# 
# $Log$
# Revision 1.3  2011/12/06 13:56:37  paul
# Cleanup.
#
# Revision 1.2  2011/12/06 13:46:31  paul
# Cleanup.
#
# Revision 1.1  2001/06/21 09:37:07  houghton
# Initial Version.
#
# Revision 5.5  1999/12/28 17:47:01  houghton
# Comment out debug 'set -x'.
#
# Revision 5.4  1999/12/28 17:45:24  houghton
# Bug-Fix: get an name for anon user.
#
# Revision 5.3  1999/12/28 17:42:53  houghton
# Turn on debug output for testing.
#
# Revision 5.2  1999/12/28 17:40:15  houghton
# Bug-Fix: fixed user id for anon ftp.
#
# Revision 5.1  1999/10/29 21:48:40  houghton
# Initial Version.
#
#

# Local Variables:
# mode:ksh
# End:
