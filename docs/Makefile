#
# Title:        Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
# 
#   Build rules and targets for the Project's Documentation
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

makefile_type   = doc
make_target     = html
make_cfg_ver    = 6.01
show_commands   = # true
check_install   = true
force           = # true

PRJ_TOPDIR  = ..
config_dir  	= $(PRJ_TOPDIR)/src/config

include $(config_dir)/00-Makefile.cfg
include Make/make.cfg.$(make_cfg_ver)

# DOC_MAN_SUBDIR        = docs/man


# **** S U B D I R  T A R G E T S ****

SUBDIR_TARGETS          = clean realclean default all html man

# ****H E L P   V A R I A B L E S ****

HELP_CONFIG_VARS        =	\
        XALAN_DEBUG		\

HELP_TARGETS		=	\
	$(SUBDIR_TARGETS)	\
	install			\
	install_docs		\
	install_html		\
	install_man		\
	install_all		\
	dist_html		\
	$(SUBDIR_TARGETS)

# **** P H O N Y   T A R G E T S

PHONY_TARGETS           = $(HELP_TARGETS)

# **** S E T U P  V A R S ****

SETUP_TARGETS   =        	    \
        src/dtd  	            \
        src/dtd/common              \
        src/dtd/project.ent         \
        src/xsl                     \
        src/xsl/common

PROJECT_ENT_VARS        =       \
        PROJECT_NAME            \
        PROJECT_VER             \
        PROJECT_VER_MAJOR       \
        PROJECT_VER_MINOR       \
        PROJECT_VER_RELEASE     \
        PROJECT_DIR             \
	PROJECT_EXTRACT_DIR	\
        PROJECT_XML_CONTACT     \
        PROJECT_CONTACT_NAME    \
        PROJECT_CONTACT_EMAIL   \
        PROJECT_CONTACT_PHONE   \
	WWW_TOOLS_DIR		\
	WWW_TOOLS_PAGE		\
	PERL_HTML_URL		\

# **** T A R G E T  V A R S ****
SUBDIRS		=	\
	src

#
# =USE_CURRENT_MAKEFILE=
#

# **** T A R G E T S ****

include Make/make.cfg.targets.doc.$(make_cfg_ver)

# **** S E T U P   T A R G E T S ****

src/dtd src/xsl:
	$(hide) $(mkdirhier_cmd) $@

src/dtd/common:
	$(hide) cd src/dtd			\
	&& rm -f common				\
	&& ln -sf $(TOOL_DIR)/share/dtd common

src/xsl/common:
	$(hide) cd src/xsl			\
	&& rm -f common				\
	&& ln -sf $(TOOL_DIR)/share/xsl common

src/dtd/project.ent:	$(config_dir)/00-Makefile.cfg   \
			$(config_dir)/Setup.cfg         \
			Makefile                        \
			$(force_target)
	$(hide) rm -f $@
	$(hide) $(foreach var,$(PROJECT_ENT_VARS),                      \
	  echo "<!ENTITY $(subst _,.,$(subst PROJECT_,PRJ.,$(var)))     \
	    \"$($(var))\">" >> $@; )
	$(hide) echo \<!ENTITY PRJ.DESC \"                      \
		`cat $(config_dir)/.prjdesc.txt` \"\> >> $@
	@echo "+ Updated $@."

.doctools:
	$(hide) cd $(PRJ_TOPDIR)/..				\
	&& $(MAKE) -f $(PROJECT_DIR)/support/Support.Makefile	\
		PROJECT_DIR=$(PROJECT_DIR)			\
		EXTRACT_DIR=`pwd`				\
		tools_host=$(tools_host)			\
		doctools	      				\
	$(hide) touch $@

setup: $(SETUP_TARGETS)
	@echo "+ src/docs setup complete"

$(SUBDIR_TARGETS):: setup
	$(call make_subdirs,$@,$(SUBDIRS),$($(@)_exports) $(exports))

default:: html

all:: html

clean::
	rm -f core

realclean:: clean
	rm -f src/dtd/project.ent
	rm -f *~


dist_html:: default
	$(hide) rm -f $(PROJECT_NAME)-html.tar.Z			\
	              $(PROJECT_NAME)-html.tar				\
	&& mv html $(PROJECT_NAME)					\
	&& cd $(PROJECT_NAME)						\
	&& find . -type f > .filelist					\
	&& cd ..							\
	&& echo 'rm -f `cat .filelist`' > $(PROJECT_NAME)/rm_files.sh	\
	&& chmod +x  $(PROJECT_NAME)/rm_files.sh			\
	&& tar cf $(PROJECT_NAME)-html.tar $(PROJECT_NAME)		\
	&& mv $(PROJECT_NAME) html					\
	&& compress $(PROJECT_NAME)-html.tar				\
	&& echo "+ Created $(PROJECT_NAME)-html.tar"



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
