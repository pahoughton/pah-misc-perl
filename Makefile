#
# Title:        Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
# 
#   This is the Top Level Makefile for PerlUtils. Before you build
#   any of the targets in this makefile, you must setup the project
#   using the Setup.Makefile in this directory. Please refer to it for
#   more details.
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
force		= # true

PRJ_TOPDIR	= .
config_dir  	= $(PRJ_TOPDIR)/src/config

# #### If you got an error here, see Setup.Makefile ####
include $(config_dir)/00-Makefile.cfg
-include Make/make.cfg.$(make_cfg_ver)

# cvs_tag		=

SUBDIRS		= docs src test

TARGETS		= $(standard_targets) dist dist_html

HELP_TARGETS	= $(TARGETS)

PHONY_TARGETS	= $(HELP_TARGETS)

include Make/make.cfg.targets.common.$(make_cfg_ver)

default check install_debug install_default install_lib_all:
	$(call make_subdirs,$@,src,$($(@)_exports))

rebuild_support_libs:
	$(call rebuild_libs,$(SUPPORT_ITEMS))

install install_all:
	$(call make_subdirs,$@,src docs,$($(@)_exports))


dist_source:
	$(call make_dist_from_cvs,$(cvs_tag),$(PROJECT_DIR))

dist_html:
	$(call make_subdirs,$@,docs,$($(@)_exports) $(exports))

# Detail Documentation
#
# Control Variables
#
#   show_commands   if this is true, the commands executed during the
#		    build will be output. Normally these commands are
#		    hidden and the only thing output is short messages
#		    indicating the items being built
#
#   check_install   if this is true, install and install_all will NOT
#		    overwrite an installed version.
#
#   force	    If this is not empty, force the rebuild of all
#		    targets even if none of the dependencies are out
#		    of date.
#
#   cvs_tag	    Use to specify the cvs TAG value for dist_sources.
#		    This value must be specified on the command line
#		    when building the 'dist_sources' target. For
#		    exammple: make dist_sources cvs_tag=MY_PRJ_1_01
#
# Help variables
#
#   HELP_TARGETS	Add any targets you create that should be
#			listed when a user performs a `make help'.
#
# Target Variables
#
#   TARGETS		All the top level targets for this Makefile.
#
#   PHONY_TARGETS	All list of the phony targets (i.e. not real
#			files) that you have added to this makefile
#			which should be appended to the .PHONY:
#			target. For more information, see make(info).
#

#
# Revision Log:
#
#
# %PL%
#
#

# Local Variables:
# mode:makefile
# End:
