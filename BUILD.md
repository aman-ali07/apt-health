# Build Guide

## Package build

```bash
./install.sh --root .
cp -r debian DEBIAN
chmod 755 DEBIAN/postinst DEBIAN/prerm
dpkg-deb --build . apt-health_1.0.0_amd64.deb
```

## Clean staging files

```bash
rm -rf DEBIAN usr
```

## Test install

```bash
sudo dpkg -i apt-health_1.0.0_amd64.deb
apt-health version
```
