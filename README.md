# QMAP Activation Script for Modems

This repository provides a shell script that activates QMAP (Qualcomm MSM Interface) on modems connected via `cdc-wdm` interfaces. QMAP enhances data throughput by aggregating multiple data streams into a single IP session over the modem.

## Features
- Configures the modem with QMAP, enabling efficient data transfer via multiple MUX (multiplexing) channels.
- Sets up modem data formats, profiles, and network configurations.
- Automatically configures the modem's IP address, netmask, and gateway.
- Sets default network routing and DNS resolvers for Android systems.

## Prerequisites
- A modem connected to your system that supports QMAP.
- `qmicli` tool installed for interacting with the modem.
- Root privileges for network and system modifications.

## Usage

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/MrMsM1/qmap.git
   cd qmap
   chmod +x activate_qmap.sh
   sudo ./activate_qmap.sh /dev/cdc-wdmX
