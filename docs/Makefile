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
make_target     = default
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

SUBDIR_TARGETS          = $(standard_targets) html

# ****H E L P   V A R I A B L E S ****

HELP_CONFIG_VARS        =       \
        XALAN_DEBUG

HELP_TARGETS            = setup html

# **** P H O N Y   T A R G E T S

PHONY_TARGETS           = $(HELP_TARGETS) html

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
        PROJECT_XML_CONTACT     \
        PROJECT_CONTACT_NAME    \
        PROJECT_CONTACT_EMAIL   \
        PROJECT_CONTACT_PHONE   \

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
	$(hide) cd dtd && ln -s $(TOOL_DIR)/share/dtd common

src/xsl/common:
	$(hide) cd xsl && ln -s $(TOOL_DIR)/share/xsl common

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
