#
# File:         Support.Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
#
#   This makefile retrieves, builds and installs all prerequisite
#   suppport tools and libraries needed by this project. If the
#   correct version of any of these tools is already installed, no
#   action will be take for those tools.
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

include Make/make.cfg.$(make_cfg_ver)

include $(PROJECT_DIR)/support/.makeconfigs.configvars

config_dir	= $(PROJECT_DIR)/src/config

SUPPORT_DIRS		= $(perlmods_build_dir)

TERM_SIZE_NAME		= Term::Size
TERM_SIZE_VER		= 0.2
TERM_SIZE_DOC		= Term::Size(3)
TERM_SIZE_tar		= Term-Size-$(TERM_SIZE_VER).tar.gz
TERM_SIZE_target	= $(perlmods_lib_os_dir)/Term/Size.pm


SUPPORT_PROJECTS	=		\


SUPPORT_PERLMODS	=		\
	TERM_SIZE

SUPPORT_LIBS		=		\


SUPPORT_TOOLS		=		\
	$(MAKE_CONFIGS_TOOLS)

SUPPORT_ITEMS	=			\
	TERM_SIZE


#
# Targets
#

include Make/make.cfg.targets.support.$(make_cfg_ver)

$(TERM_SIZE_target): $(tools_archive_dir)/$(TERM_SIZE_tar)
	$(hide) cd $(perlmods_build_dir)	\
	&& zcat $< | tar xf -			\
	&& cd Term-Size-$(TERM_SIZE_VER)	\
	&& perl Makefile.PL			\
	&& make					\
	&& make test				\
	&& make install				\
	&& [ -f $@ ]				\
	&& touch $@

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
