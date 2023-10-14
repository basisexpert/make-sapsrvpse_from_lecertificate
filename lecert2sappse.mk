# MIT License
#
# Copyright (c) 2023 Mikhail Prusov, mprusov@basisexpert.tech
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

SHELL:=/bin/bash

#
# Optional Variables
#
PSENAME             ?= SAPSSLS
PSEPIN              ?= basisexpert
ISRGROOTX1_FIX      ?= 1
ISRGROOTX1_FILE     ?= $(SECUDIR)/isrgrootx1.pem
CERT_FILE           ?= $(RENEWED_LINEAGE)/cert.pem
PRIVKEY_FILE        ?= $(RENEWED_LINEAGE)/privkey.pem
CHAIN_FILE          ?= $(RENEWED_LINEAGE)/chain.pem
PSE_BACKUP_SUFFIX   ?= .backup
SAPGENPSE_OPTS      ?= #
MOVE_CMD            ?= mv -b
RM_CMD              ?= rm -f

#
# Runtime Variables
#
PSE_FILE          = $(SECUDIR)/$(PSENAME).pse
PSE_BACKUP_FILE   = $(SECUDIR)/$(PSENAME)$(PSE_BACKUP_SUFFIX).pse
CRED_FILE         = $(SECUDIR)/cred_v2
SAPGENSE_PIN_OPT  = -x $(PSEPIN) 
SAPGENSE_IMP_OPTS := -r $(CHAIN_FILE) -c $(CERT_FILE) $(PRIVKEY_FILE)
PSE_SOURCES       := $(CERT_FILE) $(PRIVKEY_FILE) $(CHAIN_FILE)

# Process ISRGROOTX1_FIX 
ifeq ($(ISRGROOTX1_FIX),)
	ISRGROOTX1_FIX := 1
endif
ifneq ($(ISRGROOTX1_FIX),0)
	SAPGENSE_IMP_OPTS := -r $(ISRGROOTX1_FILE) -r $(CHAIN_FILE) -c $(CERT_FILE) $(PRIVKEY_FILE)
	PSE_SOURCES       := $(ISRGROOTX1_FILE) $(CERT_FILE) $(PRIVKEY_FILE) $(CHAIN_FILE)
endif

#
# Tasks
#
TARGET = pse cred
all: $(TARGET) ## make RENEWED_LINEAGE=<let's encrypt certificate path> SECUDIR=<SAP PSE Store Directory>

.PHONY: pse
pse: $(PSE_FILE) ## make pse RENEWED_LINEAGE=<let's encrypt certificate path> SECUDIR=<SAP PSE Store Directory>

.PHONY: cred
cred: $(CRED_FILE) ## make cred RENEWED_LINEAGE=<let's encrypt certificate path> SECUDIR=<SAP PSE Store Directory>

# Generate SAP PSE File
$(PSE_FILE): $(PSE_SOURCES)
	@-$(MOVE_CMD) $(PSE_FILE) $(PSE_BACKUP_FILE)
	@sapgenpse $(SAPGENPSE_OPTS) import_p8 -p $(PSE_FILE) $(SAPGENSE_PIN_OPT) $(SAPGENSE_IMP_OPTS)

# Generate credential file
$(CRED_FILE): $(PSE_FILE)
	@sapgenpse $(SAPGENPSE_OPTS) seclogin -p $(PSE_FILE) $(SAPGENSE_PIN_OPT)

$(ISRGROOTX1_FILE):
ifeq ($(ISRGROOTX1_FIX),1)
	@curl -k https://letsencrypt.org/certs/isrgrootx1.pem.txt -o $(ISRGROOTX1_FILE)
endif

.PHONY: display
variables:
	@echo PSE_SOURCES    : \"$(PSE_SOURCES)\"
	@echo ISRGROOTX1_FIX : \"$(ISRGROOTX1_FIX)\"

.PHONY: clean
clean:
	@$(RM_CMD) $(PSE_FILE) $(CRED_FILE)
ifeq ($(ISRGROOTX1_FIX),1)
	@$(RM_CMD) $(ISRGROOTX1_FILE)
endif

.PHONY: help
help:
	@echo "Usage: make <options>"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'
