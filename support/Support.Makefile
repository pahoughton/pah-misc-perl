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

setup_output	= >> $(EXTRACT_DIR)/$(PROJECT_DIR)/.setup.output 2>&1

SUPPORT_DIRS		= $(perlmods_build_dir) $(tools_build_dir)

DOCTOOLS_EXTRACT_DIR	= $(tools_build_dir)
DOCTOOLS_NAME		= DocTools
DOCTOOLS_VER		= 2
DOCTOOLS_DOC		= $(tools_html_dir)/Tools/DocTools
DOCTOOLS_DESC_CMD	= \
	cat $(DOCTOOLS_EXTRACT_DIR)/$(DOCTOOLS_build_dir)/src/config/.prjdesc.txt
DOCTOOLS_CLASSPATH	= \
	$(tools_java_dir)/DocTools/com.wcom.cisid.DocTools.Xml.Element-$(DOCTOOLS_VER).jar
DOCTOOLS_dir		= $(DOCTOOLS_NAME)-$(DOCTOOLS_VER)
DOCTOOLS_build_dir	= $(DOCTOOLS_dir)
DOCTOOLS_tar		= $(DOCTOOLS_NAME)-$(DOCTOOLS_VER).tar.gz
DOCTOOLS_target		= $(TOOL_DIR)/share/dtd/DocTools/contents.dtd

TERM_SIZE_EXTRACT_DIR	= $(perlmods_build_dir)
TERM_SIZE_NAME		= Term::Size
TERM_SIZE_VER		= 0.2
TERM_SIZE_DOC		= Term::Size(3)
TERM_SIZE_DESC_CMD	=						\
	echo Term::Size is a Perl module which provides a		\
		straightforward way to retrieve the terminal size.

TERM_SIZE_build_dir	= Term-Size-$(TERM_SIZE_VER)
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

$(DOCTOOLS_target): $(tools_archive_dir)/$(DOCTOOLS_tar)
	$(hide) echo "+ Installing $(DOCTOOLS_NAME) ...\c"	\
	&& cd $(DOCTOOLS_EXTRACT_DIR)				\
	&& rm -rf $(DOCTOOLS_dir)				\
	&& $(zcat_cmd) $< | tar xf -				\
	&& $(make_cmd) -f $(DOCTOOLS_build_dir)/Setup.Makefile	\
		setup						\
		TOOL_DIR=$(TOOL_DIR)				\
		EXTRACT_DIR=$(DOCTOOLS_EXTRACT_DIR)		\
		PROJECT_DIR=$(DOCTOOLS_build_dir)		\
		INSTALL_BASE_DIR=$(TOOL_DIR)			\
		INSTALL_DOC_HTML_DIR=$(DOCTOOLS_DOC)		\
	&& $(make_cmd) -C $(DOCTOOLS_build_dir) install_all	\
		check_install=false				\
	&& [ -f $@ ]						\
	&& touch $@						\
	&& echo " Done -" `date`

$(TERM_SIZE_target): $(tools_archive_dir)/$(TERM_SIZE_tar)
	$(hide) echo "+ Installing $(TERM_SIZE_NAME) ...\c"	\
	&& cd $(TERM_SIZE_EXTRACT_DIR)				\
	&& zcat $< | tar xf -					\
	&& cd $(TERM_SIZE_build_dir)				\
	&& perl Makefile.PL $(setup_output)			\
	&& make $(setup_output)					\
	&& make test $(setup_output)				\
	&& make install $(setup_output)				\
	&& [ -f $@ ]						\
	&& touch $@						\
	&& echo " Done -" `date`

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
