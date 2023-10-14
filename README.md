# Generate SAP Server PSE from Let's Encrypt certificate

## Using lecert2sappse.mk

The make-file `lecert2sappse.mk` should be started from `<sapsid>adm` user.

To generate PSE you need pass two parameters: `RENEWED_LINEAGE` and `SECUDIR`.

The `RENEWED_LINEAGE` is path to Let's encrypt certificate (for example, "/etc/letsencrypt/live/example.com").

The `SECUDIR` is SAP classical variable points to SAP PSE Store Directory.

The sample of using `lecert2sappse.mk` to generate PSE from Lets' Encrypt certificate for SAP Web Dispather `W91`:

```bash
make -f lecert2sappse.mk SECUDIR=/usr/sap/W91/W91/sec RENEWED_LINEAGE=/etc/letsencrypt/live/example.com
```

## Using lecert2sapinstancepse.sh

The script `lecert2sapinstancepse.sh` is bash-wrapper for `lecert2sappse.mk`.
The script generates PSE for given SAP Instance.
Additionally the script can sends signal `KILL_HUP` to reload of process. This is valuable for such proceeses as SAP ICM or SAP Web Dispatcher.

The script can be started both as from `<sapsid>adm` user and any user permitted sudo into `<sapsid>adm`.

The sample of using `lecert2sapinstancepse.sh` to generate PSE from Lets' Encrypt certificate:

```bash
RENEWED_LINEAGE=/etc/letsencrypt/live/example.com SAPSYSTEMNAME=W91 INSTANCE_NAME=W91 KILL_HUP=wd ./lecert2sapinstancepse.sh
```
