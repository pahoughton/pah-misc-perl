#
# File:         Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
#
#   This Makefile builds the targets in all the source subdirectories.
#
# Notes:
#
# Author:	Paul Houghton <Paul.Houghton@wcom.com>
# Created:	5/30/101 using GenProject 6.01.01
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

show_commands 	= # true
check_install	= true

PRJ_TOPDIR	= ..
config_dir	= $(PRJ_TOPDIR)/src/config

include $(config_dir)/00-Makefile.cfg
include Make/make.cfg.$(make_cfg_ver)

SUBDIRS		=		\
	App/Debug		\
	Text/Fill		\
	Doc/Self		\
	App/Options		\
	ParseCxx

TARGETS		= $(standard_targets) debug

HELP_TARGETS	= $(TARGETS)
PHONY_TARGETS	= $(TARGETS)

include Make/make.cfg.targets.common.$(make_cfg_ver)

all default check install_all install install_lib_all::
	$(hide) subdirs="$(SUBDIRS)";		\
	for dir in $$subdirs ; do		\
	  echo "+ Makeing $@ in $$dir ...";	\
	  ( cd $$dir				\
	    && $(TOOL_DIR)/bin/perl Makefile.PL	\
	    && make				\
	    && make test			\
	    && make install ) || exit 1;	\
	done


#
# Revision Log:
#
#
# %PL%
#
#

# Set XEmacs mode
#
# Local Variables:
# mode:makefile
# End:
