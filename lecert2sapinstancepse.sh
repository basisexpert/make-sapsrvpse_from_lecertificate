#!/usr/bin/env bash

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

# RENEWED_LINEAGE
# SAPSYSTEMNAME
# INSTANCE_NAME
# PSENAME
# KILL_HUP

# Eval SAP Instance PSE Store Directory
SECUDIR="/usr/sap/$SAPSYSTEMNAME/$INSTANCE_NAME/sec"

# Eval SAP System Administrator User
SIDADM_USER="${SAPSYSTEMNAME,,}adm"

[ "$USER" == "$SIDADM_USER" ] && SUDO_CMD="eval" || SUDO_CMD="sudo -i -u $SIDADM_USER sh -c"
$SUDO_CMD "make -f $(realpath $(dirname -- $0))/lecert2sappse.mk RENEWED_LINEAGE=$RENEWED_LINEAGE SECUDIR=$SECUDIR PSENAME=${PSENAME:-SAPSSLS}"
RC=$?; [ $RC ] || exit $RC

if [ ! -z "$KILL_HUP" ]; then
    PID=$(pgrep -u $SIDADM_USER $KILL_HUP)
    [ ! -z "$PID" ] && (kill -HUP $PID && echo Signal -HUP sended to process with prefix $KILL_HUP) || echo "Found no process with prefix $KILL_HUP..."
fi
