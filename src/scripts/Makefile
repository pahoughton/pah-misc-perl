#
# Make rules for perl scripts
#
# 1/23/92
#
# $Id$
#

PERL_SCRIPTS	= \
	showtables.pl	\
	tablerows.pl	\
	makesql.pl		\
	savedata.pl		\
	storedata.pl	\
	tablescripts.pl
	
SCRIPTS_PL		=	$(PERL_SCRIPTS:.pl=)


LCL_BASE_DIR	=	/usr/local
LCL_BIN_DIR		=	$(LCL_BASE_DIR)/bin


install:
	for i in $(SCRIPTS_PL); do			\
		cp $$i.pl $(LCL_BIN_DIR)/$$i;	\
		chmod 775 $(LCL_BIN_DIR)/$$i;	\
	done
