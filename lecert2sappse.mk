# MIT License
#
# Copyright (c) 2023 Mikhail Prusiv, mprusov@basisexpert.tech
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
LE_DIRECTORY        ?= /etc/letsencrypt
LE_ISRGROOTX1_FILE  ?= $(SECUDIR)/isrgrootx1.pem
CERT_FILE           ?= $(LE_DIRECTORY)/live/$(LE_CERTIFICATE)/cert.pem
PRIVKEY_FILE        ?= $(LE_DIRECTORY)/live/$(LE_CERTIFICATE)/privkey.pem
CHAIN_FILE          ?= $(LE_DIRECTORY)/live/$(LE_CERTIFICATE)/chain.pem
PSE_BACKUP_SUFFIX   ?= .backup
SAPGENPSE_OPTS  	?= #
MOVE_CMD            ?= mv -b
RM_CMD              ?= rm -f

#
# Runtime Variables
#
SAPGENSE_PIN_OPT = -x $(PSEPIN) 
SAPGENSE_IMP_OPTS = -r $(LE_ISRGROOTX1_FILE) -r $(CHAIN_FILE) -c $(CERT_FILE) $(PRIVKEY_FILE)
PSE_FILE = $(SECUDIR)/$(PSENAME).pse
CRED_FILE = $(SECUDIR)/cred_v2
PSE_BACKUP_FILE = $(SECUDIR)/$(PSENAME)$(PSE_BACKUP_SUFFIX).pse

#
# Tasks
#
TARGET = $(PSE_FILE) $(CRED_FILE)
all: $(TARGET) ## make LE_CERTIFICATE=<lets encrypt certificate> SECUDIR=<SAP PSE Store Directory>

# Generate SAP PSE File
$(PSE_FILE): $(LE_ISRGROOTX1_FILE) $(CERT_FILE) $(PRIVKEY_FILE) $(CHAIN_FILE)
	@-$(MOVE_CMD) $(PSE_FILE) $(PSE_BACKUP_FILE)
	@sapgenpse $(SAPGENPSE_OPTS) import_p8 -p $(PSE_FILE) $(SAPGENSE_PIN_OPT) $(SAPGENSE_IMP_OPTS)

# Generate credential file
$(CRED_FILE): $(PSE_FILE)
	@sapgenpse $(SAPGENPSE_OPTS) seclogin -p $(PSE_FILE) $(SAPGENSE_PIN_OPT)

$(LE_ISRGROOTX1_FILE):
	@curl -k https://letsencrypt.org/certs/isrgrootx1.pem.txt -o $(LE_ISRGROOTX1_FILE)

.PHONY: clean
clean:
	$(RM_CMD) $(TARGET)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
