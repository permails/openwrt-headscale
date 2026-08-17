# openwrt-headscale

OpenWrt package feed for Headscale (an open-source, self-hosted Tailscale control server).

## Features

- Native OpenWrt package with standard Golang toolchain support.
- Managed by OpenWrt procd init system and UCI configuration.
- Automatic generation of Headscale `config.yaml` from `/etc/config/headscale`.
- Automatic symlink (`/etc/headscale/config.yaml`) for seamless `headscale` CLI usage in SSH terminal.
- Preserved configuration, SQLite database, and cryptographic keys across `sysupgrade`.

## IMPORTANT: Storage Considerations & Flash Memory Warning

Headscale uses an SQLite database (`/etc/headscale/db.sqlite`) to maintain node registrations, machine keys, user namespaces, and routing states.

Please read the following storage guidelines carefully before deployment:

1. **eMMC, SSD, and USB Storage Devices (Recommended)**
   - Devices with built-in eMMC storage (such as JDCloud routers with 64G/128G eMMC), x86 routers, or devices booting from USB/NVMe/SSD drives have hardware wear-leveling controllers and can safely run Headscale with standard persistent paths.

2. **Standard SPI NOR / NAND Flash Routers (Caution)**
   - Small SPI flash chips (e.g., 16MB, 32MB, or 128MB raw flash) have limited write cycles (P/E endurance).
   - Continuous SQLite writes and Write-Ahead Log (WAL) checkpoints may cause excessive flash wear over time.
   - If running on SPI Flash devices without eMMC/SSD, it is strongly recommended to either:
     - Attach a reliable USB drive and configure `sqlite_path` under the mounted partition (e.g., `/mnt/sda1/headscale/db.sqlite`), or
     - Regularly back up the database if moved to RAM (`/tmp`).

## Building

1. Add this package to your OpenWrt build environment:
   ```bash
   cd /path/to/openwrt
   git clone https://github.com/permails/openwrt-headscale.git package/headscale
   ```

2. Update feeds and ensure Golang host compiler is installed:
   ```bash
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   ```

3. Select the package in menuconfig:
   ```bash
   make menuconfig
   # Navigate to: Network -> VPN -> headscale (select <*>)
   ```

4. Compile:
   ```bash
   make package/headscale/compile V=s
   ```

## Configuration

Configuration is located in `/etc/config/headscale`.

Enable and start the service:
```bash
uci set headscale.server.enabled='1'
uci commit headscale
/etc/init.d/headscale enable
/etc/init.d/headscale start
```

## CLI Usage

Once the service is running, manage Headscale directly via standard commands:
```bash
# Create a user namespace
headscale users create myuser

# Generate a pre-auth key
headscale preauthkeys create -u myuser --reusable --expiration 24h

# List registered nodes
headscale nodes list
```

## Firewall

If exposing Headscale to external networks, ensure the listening port (default TCP 8080) and STUN port (default UDP 3478) are allowed in `/etc/config/firewall`.

## License

Licensed under the BSD 3-Clause License.
