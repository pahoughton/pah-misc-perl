#
# File:         MakeConfigs.Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
#
#   This Makefile is used to setup, build and Install MakeConfigs
#   for use by the project.
#
# Notes:
#
# Author:	Paul Houghton - <paul4hough@gmail.com>
# Created:	03/05/01 04:44
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

SHELL	= /bin/ksh
hide	= @

tools_archive_dir	= $(TOOL_DIR)/src/Archives
tools_build_dir		= $(TOOL_DIR)/src/Build/Tools
tools_inc_dir		= $(TOOL_DIR)/include
tools_bin_dir		= $(TOOL_DIR)/bin
tools_info_dir		= $(TOOL_DIR)/info

make_configs_vars_file	= \
	$(PROJECT_DIR)/support/.makeconfigs.configvars

setup_output	= >> $(EXTRACT_DIR)/$(PROJECT_DIR)/.setup.output 2>&1

GZIP_SUPPORT_TYPE	= TOOL
GZIP_NAME		= gzip
GZIP_VER		= 1.3.12
GZIP_DOC_HTML		= http://www.gnu.org/software/gzip
GZIP_DOC		= gzip(info)  gzip(1)
GZIP_DESC_CMD		=	\
	echo gzip is a program for compressing and decompressing files.
GZIP_EXTRACT_DIR	= $(tools_build_dir)
GZIP_build_dir		= $(GZIP_NAME)-$(GZIP_VER)
GZIP_tar		= $(tools_archive_dir)/gzip-$(GZIP_VER).tar
GZIP_target		= $(tools_bin_dir)/gzip

MAKE_CONFIGS_SUPPORT_TYPE	= TOOL

MAKE_CONFIGS_NAME		= MakeConfigs
MAKE_CONFIGS_VER		= $(make_cfg_ver)
MAKE_CONFIGS_DOC_HTML		= $(WWW_TOOLS_ROOT)/MakeConfigs
MAKE_CONFIGS_DOC		= 
MAKE_CONFIGS_DESC_CMD		= \
	cat $(MAKE_CONFIGS_EXTRACT_DIR)/$(MAKE_CONFIGS_build_dir)/src/config/.prjdesc.txt
MAKE_CONFIGS_EXTRACT_DIR	= $(tools_build_dir)
MAKE_CONFIGS_build_dir		= $(MAKE_CONFIGS_NAME)-$(MAKE_CONFIGS_VER)
MAKE_CONFIGS_tar		= \
	$(tools_archive_dir)/$(MAKE_CONFIGS_NAME)-$(MAKE_CONFIGS_VER).tar.gz
MAKE_CONFIGS_target	= $(tools_inc_dir)/Make/make.cfg.$(MAKE_CONFIGS_VER)

MAKE_CONFIGS_ITEMS	= GZIP MAKE_CONFIGS

MAKE_CONFIGS_SUPPORT_ITEMS	=	\
	TCL				\
	TK				\
	EXPECT				\
	LIB_DB				\
	DEJAGNU				\
	BASH				\
	CPROTO				\
	PERL				\
	PERLUTILS			\
	DOCTOOLS

MAKE_CONFIGS_PROJECT_VARS	=	\
	MAKE_CONFIGS_PROJECT_VARS	\
					\
	MAKE_CONFIGS_ITEMS		\
					\
	GZIP_SUPPORT_TYPE		\
	GZIP_NAME			\
	GZIP_VER			\
	GZIP_DOC			\
	GZIP_DOC_HTML			\
	GZIP_DESC_CMD			\
	GZIP_EXTRACT_DIR		\
					\
	MAKE_CONFIGS_SUPPORT_TYPE	\
	MAKE_CONFIGS_EXTRACT_DIR	\
	MAKE_CONFIGS_NAME		\
	MAKE_CONFIGS_VER		\
	MAKE_CONFIGS_DOC		\
	MAKE_CONFIGS_DOC_HTML		\
	MAKE_CONFIGS_DESC_CMD		\
	MAKE_CONFIGS_SUPPORT_ITEMS	\

anon_ftp_cmd	= $(PROJECT_DIR)/support/AnonFtp.ksh
zcat_cmd	= $(tools_bin_dir)/zcat
mkdirhier_cmd	= $(PROJECT_DIR)/support/mkdirhier.sh

tools_subdirs	=		\
	$(tools_archive_dir)	\
	$(tools_build_dir)	\
	$(tools_bin_dir)

setup_targets	=		\
	$(GZIP_target)		\
	$(MAKE_CONFIGS_target)

MAKEOVERRIDES	=

#
# Targets
#
default:
	@echo "+ You should NOT directly call this makefile. the following"
	@echo "+ variables are needed:"
	@echo
	@echo "+    PROJECT_DIR=$(PROJECT_DIR)"
	@echo "+    TOOL_DIR=$(TOOL_DIR)"
	@echo "+    make_cfg_ver=$(make_cfg_ver)"
	@echo "+    tools_host=$(tools_host)"
	@echo "+    tools_host_dir=$(tools_host_dir)"

prep:
	$(hide) chmod +x $(anon_ftp_cmd)
	$(hide) chmod +x $(mkdirhier_cmd)


$(tools_subdirs):
	$(hide) $(mkdirhier_cmd) $@

tools_dirs: $(tools_subdirs)

$(GZIP_tar) $(MAKE_CONFIGS_tar):
	$(hide) echo "+ Ftp'ing `basename $@` from $(tools_host) ...\c"
	$(hide) $(anon_ftp_cmd)						\
	    $(tools_host)						\
	    $(tools_host_dir)/`basename $@` $(tools_archive_dir)
	$(hide) echo "Done -" `date`

$(GZIP_target): $(GZIP_tar)
	$(hide) echo "+ Installing $(GZIP_NAME) ...\c"		\
	&& cd $(GZIP_EXTRACT_DIR)				\
	&& rm -rf  $(GZIP_build_dir)				\
	&& tar xf $(GZIP_tar)					\
	&& cd $(GZIP_build_dir)					\
	&& ./configure --prefix=$(TOOL_DIR) $(setup_output)	\
	&& $(MAKE) $(setup_output)				\
	&& $(MAKE) install $(setup_output)			\
	&& echo " Done -" `date`

$(MAKE_CONFIGS_target):
	$(hide) echo "+ Installing $(MAKE_CONFIGS_NAME) ...\c"		\
	&& cd $(MAKE_CONFIGS_EXTRACT_DIR)				\
	&& $(tools_bin_dir)/zcat $(MAKE_CONFIGS_tar) | tar xf -		\
	&& $(MAKE) -f $(MAKE_CONFIGS_build_dir)/Setup.Makefile setup	\
	&& $(tools_bin_dir)/make -C MakeConfigs-$(make_cfg_ver)		\
		install							\
	&& echo " Done -" `date`

config_vars_cmd =						\
	$(foreach var, $(MAKE_CONFIGS_PROJECT_VARS),		\
	    echo "$(var)	= $($(var))" >> $@; )

$(make_configs_vars_file): .force
	@echo "# This file was generated by MakeConfigs.Makefile" > $@
	@$(config_vars_cmd)

gen_config_file:
	$(hide) $(tools_bin_dir)/make				\
		-f $(PROJECT_DIR)/support/MakeConfigs.Makefile	\
		$(make_configs_vars_file)

setup: prep tools_dirs $(setup_targets) gen_config_file


.force:


#
# Detailed Documentation
#
# Targets
#
#   setup:
#
#	Retreive, setup and build the version of MakeConfigs specified
#	by $(make_cfg_ver). If this version is already installed,
#	no action will be taken. The following variable must be set on
#	the command line (usually through a top level setup makefile)
#	for the targets to be build properly:
#
#	    PROJECT_DIR
#	    TOOL_DIR
#	    EXTRACT_DIR
#	    make_cfg_ver
#	    tools_host
#	    tools_host_dir
#
#	See the Variables section of this documentation for a description
#	of each of these variables.
#
#	Once MakeConfigs is built and installed, the setup target also
#	creates the file '.makeconfigs.configvars'. This has all the
#	the settins of all the variables listed in
#	'MAKE_CONFIGS_PROJECT_VARS'. It can be included in other
#	Makefiles to utilized these values.
#
# Variables
#
#   PROJECT_DIR
#
#	The name of the top level directory for the project.
#
#   TOOL_DIR
#
#	This is not a Makefile variable, but it is a very important
#	environment variable. It must be set and $TOOL_DIR/bin
#	must be in your path so that the prerequisit programs that
#	are installed will be found befor any other verion of these
#	programs that might be on the system.
#
#   EXTRACT_DIR
#
#	The full path directory just above the top level directory for
#	the project. Normally this is set with something like:
#
#	    EXTRACT_DIR=`pwd`
#
#	In the command that builds the setup target in this makefile.
#
#   make_cfg_ver
#
#	The version of MakeConfigs to use
#
#   tools_host
#
#	The directory on the anonymous ftp host that contains all the
#	prerequisit pagckages.
#
#   tools_host_dir
#
#	The directory on the anonymous ftp host that contains all the
#	prerequisit pagckages.
#
#   hide
#
#	All commands are prefixed with this variable so the actual
#	commands can be hidden durring the build. It defaults to `@'
#	so the commands are hidden, to see the commands, set it to the
#	empty string (i.e. hide= ).
#
#

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
