# Migrating an existing installation

The installer detects the earlier `/etc/dgx-fan-control.json` deployment and skips automatic configuration. It does not disable, stop, replace or unload that deployment.

Before migration, record the existing mode, unit/configuration backups and module owner. Arrange a maintenance period, release the old override through its original API and confirm its fresh restoration acknowledgement. Stop only its old API/channel services after they have no pending operation; do not leave two independently writable brokers controlling the same unit.

Install/configure the suite on the qualified profile, verify native mode and actual RPM/temperature, then explicitly select the desired mode. Keep rollback copies of the original services and files. Do not use `rmmod --force`, disable Secure Boot automatically, or overwrite firmware to bypass a compatibility failure.

This public project does not contain site-specific migration scripts, machine identities, certificates, private policy sources, or SSH authentication helpers. Management applications should adopt the versioned Unix/mTLS API rather than executing host shell commands.
