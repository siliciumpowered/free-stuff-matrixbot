# free-stuff-matrixbot PVC

The ZFS and mounting layout should look like this:

```text
$ ssh helium.mzimmer.net -- zfs list -r tank/infra/free-stuff-matrixbot
NAME                                                                MOUNTPOINT
tank/infra/free-stuff-matrixbot                                none
tank/infra/free-stuff-matrixbot/components                     none
tank/infra/free-stuff-matrixbot/components/storage   /srv/infra/free-stuff-matrixbot/components/storage

$ ssh helium.mzimmer.net -- ls -lahF /srv/infra/free-stuff-matrixbot/components/storage
total 5.0K
drwx------ 3 libvirt-qemu libvirt-qemu    3 Nov 29 13:36 ./
drwxr-xr-x 3 root         root         4.0K Nov 29 13:35 ../
```

This can be achieved for example by running the following commands:

```shell script
ssh helium.mzimmer.net -- zfs create -o mountpoint=none tank/infra/free-stuff-matrixbot
ssh helium.mzimmer.net -- zfs create -o mountpoint=none tank/infra/free-stuff-matrixbot/components
ssh helium.mzimmer.net -- zfs create -o mountpoint=/srv/infra/free-stuff-matrixbot/components/storage tank/infra/free-stuff-matrixbot/components/storage
ssh helium.mzimmer.net -- chown libvirt-qemu:libvirt-qemu /srv/infra/free-stuff-matrixbot/components/storage
ssh helium.mzimmer.net -- chmod 700 /srv/infra/free-stuff-matrixbot/components/storage
ssh scandium.mzimmer.net -- chown root:root /srv/infra/free-stuff-matrixbot/components/storage
ssh scandium.mzimmer.net -- chmod 755 /srv/infra/free-stuff-matrixbot/components/storage
```

After that the PVC can be created:

```shell script
make apply
```
