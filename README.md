# Generate SAP Server PSE from Let's Encrypt certificate

## Using lecert2sappse.mk

The make-file `lecert2sappse.mk` should be started from `<sapsid>adm` user.

To generate PSE you need pass two parameters: `LE_CERTIFICATE` and `SECUDIR`.

The `LE_CERTIFICATE` is name of Let's encrypt certificate.

The `SECUDIR` is SAP classical variable points to SAP PSE Store Directory.

The sample of using `lecert2sappse.mk` to generate PSE from Lets' Encrypt certificate for SAP Web Dispather `W91`:

```bash
make -f lec2sappse.mk SECUDIR=/usr/sap/W91/W91/sec LE_CERTIFICATE=example.com
```

## Using lecert2sapinstancepse.sh

The script `lecert2sapinstancepse.sh` is bash-wrapper for `lecert2sappse.mk`.

The script can be started both as from `<sapsid>adm` user and any user permitted sudo into `<sapsid>adm`.

The sample of using `lecert2sapinstancepse.sh` to generate PSE from Lets' Encrypt certificate:

```bash
LE_CERTIFICATE=example.com SAPSYSTEMNAME=W91 INSTANCE_NAME=W91 KILL_HUP=wd ./lec2sapinstancepse.sh
```
