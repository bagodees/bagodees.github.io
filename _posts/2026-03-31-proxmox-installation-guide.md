---
layout: post
title: “Installing Proxmox VE A Beginner’s Complete Guide”
date: 2026-03-31 00:00:00 +0000
categories: Homelab Proxmox
tags: proxmox virtualization homelab, linux self-hosting beginner
image:
  path: /assets/img/headers/proxmox-guide.png
---

## What Is Proxmox VE?

Proxmox Virtual Environment (VE) is a free, open-source hypervisor built on Debian Linux. It lets you run **virtual machines (VMs)** and **LXC containers** from a clean web interface. Think of it as the operating system for your homelab server — instead of running one OS on your machine, Proxmox lets you run many, all isolated from each other.

Some things you can do with Proxmox:

- Run a full Windows or Linux VM
- Deploy lightweight containers (like Docker hosts, Pi-hole, Home Assistant)
- Create snapshots and backups of everything
- Cluster multiple physical machines together

-----

## What You’ll Need

Before getting started, gather the following:

|Item                                    |Notes                                                           |
|----------------------------------------|----------------------------------------------------------------|
|A dedicated PC or server                |Proxmox will **wipe the drive**, so don’t use your daily machine|
|At least 4 GB RAM                       |8 GB+ recommended for running VMs                               |
|A 64-bit CPU with virtualization support|Intel VT-x or AMD-V                                             |
|A USB drive (8 GB+)                     |This becomes your installer — its contents will be erased       |
|A separate machine                      |To download the ISO and flash the USB                           |
|A wired Ethernet connection             |Wi-Fi is not supported during install                           |


> **Tip:** If you’re unsure whether your CPU supports virtualization, Google your CPU model + “virtualization support”. Most CPUs made after 2010 do.
> {: .prompt-tip }

-----

## Step 1: Download the Proxmox ISO

1. Head to the official Proxmox downloads page: <https://www.proxmox.com/en/downloads>
1. Click **Proxmox VE** and download the latest ISO installer (e.g., `proxmox-ve_8.x-x.iso`).
1. Always download from the official site. Verify the SHA256 checksum if you want to be thorough — the checksum is listed on the download page.

-----

## Step 2: Create a Bootable USB Drive

You’ll use a tool called **Rufus** (Windows) or **Balena Etcher** (Windows/Mac/Linux) to flash the ISO onto your USB drive.

### Using Balena Etcher (Recommended for beginners)

1. Download Etcher from <https://etcher.balena.io>
1. Open Etcher and click **Flash from file** → select your Proxmox ISO
1. Click **Select target** → choose your USB drive
1. Click **Flash!** and wait for it to finish

> **Warning:** Etcher will erase everything on the USB drive. Double-check you’ve selected the correct drive before flashing.
> {: .prompt-warning }

-----

## Step 3: Configure BIOS/UEFI Settings

Before booting from the USB, you need to make a few changes in your machine’s BIOS/UEFI. This is the settings screen that appears before your OS loads — usually accessed by pressing `DEL`, `F2`, `F10`, or `F12` during startup (the key varies by manufacturer).

### Enable Virtualization

This is the most important setting. Without it, Proxmox can’t run VMs efficiently.

- **Intel systems:** Look for **Intel VT-x** or **Intel Virtualization Technology** → set to **Enabled**
- **AMD systems:** Look for **AMD-V** or **SVM Mode** → set to **Enabled**

### Enable IOMMU (for GPU/device passthrough later)

If you ever want to pass a GPU or other PCI device directly into a VM, enable this now:

- **Intel:** Look for **VT-d** → **Enabled**
- **AMD:** Look for **AMD IOMMU** → **Enabled**

### Set Boot Order

Set your USB drive as the **first boot device**. Look for a “Boot” or “Boot Order” section and move the USB to the top.

### Disable Secure Boot

Proxmox’s installer may not work with Secure Boot enabled on some systems.

- Look for **Secure Boot** under the Security or Boot tab → set to **Disabled**

Save your changes (usually `F10`) and reboot.

-----

## Step 4: Boot the Proxmox Installer

With the USB plugged in, your machine should boot into the Proxmox installer. You’ll see a menu — select **Install Proxmox VE (Graphical)** and press Enter.

-----

## Step 5: Work Through the Installer

### 5a. Accept the License Agreement

Read through (or scroll past) the EULA and click **I agree**.

### 5b. Select the Target Disk

This is where Proxmox will be installed. Select your drive from the list.

> **Warning:** The selected drive will be completely wiped. If you have multiple drives, be absolutely sure you’re selecting the right one.
> {: .prompt-warning }

#### Choose Your Filesystem — ZFS or ext4?

After selecting your disk, click **Options** to choose a filesystem. This is one of the most important decisions you’ll make:

|Filesystem     |Best For                 |Pros                     |Cons                                  |
|---------------|-------------------------|-------------------------|--------------------------------------|
|**ext4**       |Single drive, beginners  |Simple, fast, familiar   |No built-in redundancy or checksumming|
|**ZFS RAID-0** |Single drive, power users|Data integrity, snapshots|Uses more RAM                         |
|**ZFS RAID-1** |Two drives               |Mirrored redundancy      |Requires 2 identical drives           |
|**ZFS RAID-Z1**|3+ drives                |Parity redundancy        |Requires 3+ drives                    |

**For beginners with one drive:** Start with **ext4**. It’s simple and gets the job done. You can always migrate later.

**If you have 2+ drives:** Consider **ZFS RAID-1** (mirrored). ZFS protects against silent data corruption and makes snapshots trivial.

> **Tip:** ZFS loves RAM. A general rule of thumb is 1 GB of RAM per 1 TB of storage, on top of what your VMs need. If RAM is limited, stick with ext4.
> {: .prompt-tip }

### 5c. Set Location and Timezone

Select your country and timezone. This affects system time and locale settings.

### 5d. Set Your Password and Email

- Choose a strong **root password** — this is the admin account for your entire server
- Enter an email address (used for system notifications — can be a placeholder for now)

### 5e. Configure Networking

This screen sets up your management interface — how you’ll reach the Proxmox web UI.

|Field                   |What to Enter                                        |
|------------------------|-----------------------------------------------------|
|**Management Interface**|Select your Ethernet NIC (e.g., `eno1`, `eth0`)      |
|**Hostname (FQDN)**     |Something like `pve.local` or `proxmox.home.lab`     |
|**IP Address**          |A static IP on your network (e.g., `192.168.1.50/24`)|
|**Gateway**             |Your router’s IP (e.g., `192.168.1.1`)               |
|**DNS Server**          |Your router’s IP or a public DNS like `1.1.1.1`      |


> **Tip:** Write down the IP address you assign here — you’ll use it to access the web UI after install.
> {: .prompt-tip }

### 5f. Review and Install

The final screen shows a summary of your choices. Review everything, then click **Install**. The process takes 5–10 minutes. When it finishes, remove the USB drive and click **Reboot**.

-----

## Step 6: Access the Web UI

Once your server reboots, you’ll see a terminal with a message like:

```
Welcome to the Proxmox Virtual Environment.

Please use your web browser to configure this server - connect to:

  https://192.168.1.50:8006/
```

On another machine on your network, open a browser and navigate to that address. You’ll get a certificate warning — this is expected since Proxmox uses a self-signed cert by default. Click **Advanced** → **Proceed anyway** (exact wording varies by browser).

Log in with:

- **Username:** `root`
- **Password:** The one you set during install
- **Realm:** `Linux PAM standard authentication`

Welcome to Proxmox! 🎉

-----

## Step 7: Post-Install Best Practices

Now that Proxmox is running, take some time to harden and configure it properly. These steps will save you headaches later.

### 7a. Switch to the No-Subscription Repository

By default, Proxmox points to its **Enterprise repository**, which requires a paid subscription. If you don’t have one, you’ll get errors when trying to update. Switch to the free **no-subscription repo**:

In the web UI, open a shell: **Node → Shell** (or SSH in as root), then run:

```bash
# Disable the enterprise repo
echo "# disabled" > /etc/apt/sources.list.d/pve-enterprise.list

# Add the no-subscription repo
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-no-subscription.list

# Update package lists
apt update
```

> **Note:** The no-subscription repo is perfectly stable for homelab use. The Enterprise repo simply offers faster patch releases and official support.
> {: .prompt-info }

### 7b. Run System Updates

```bash
apt update && apt full-upgrade -y
```

Reboot after major kernel updates:

```bash
reboot
```

### 7c. Dismiss the Subscription Nag (Optional)

Proxmox shows a “No valid subscription” popup on login. To remove it, run:

```bash
sed -Zi 's/res === null \|\| res === undefined \|\| \!res \|\| res\n\t\t\t/false\n\t\t\t/g' \
  /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy
```

> **Note:** This may need to be re-applied after Proxmox updates.
> {: .prompt-info }

### 7d. Configure a Network Bridge

Proxmox creates `vmbr0` (a Linux bridge) during install — this is what your VMs use to get network access. Verify it exists and is correctly configured under **Node → Network**.

If you want VMs to appear as first-class devices on your LAN (recommended), keep `vmbr0` bridged to your physical NIC. That’s the default behavior.

### 7e. Set Up Email Notifications (Optional but Recommended)

Proxmox can email you when backups complete or something goes wrong. Under **Datacenter → Notifications**, configure an SMTP relay. Services like Gmail (with an app password) or a self-hosted SMTP server work well here.

### 7f. Configure Automatic Backups

One of Proxmox’s best features is built-in backup scheduling. Set it up early — before you have VMs you’d hate to lose.

1. Go to **Datacenter → Backup**
1. Click **Add**
1. Choose a schedule (e.g., every Sunday at 2:00 AM)
1. Select which VMs/containers to back up
1. Choose a storage target (local disk to start, NAS later)
1. Set a **retention policy** (e.g., keep last 3 backups)

> **Tip:** Even if your storage is local for now, having scheduled backups means you can restore from a snapshot if a VM gets corrupted.
> {: .prompt-tip }

### 7g. Enable IOMMU in the Kernel (If You Enabled It in BIOS)

If you enabled VT-d or AMD IOMMU in BIOS, tell the kernel about it too:

**Edit the GRUB config:**

```bash
nano /etc/default/grub
```

Find the line starting with `GRUB_CMDLINE_LINUX_DEFAULT` and add the appropriate flag:

```bash
# Intel
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"

# AMD
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"
```

Then update GRUB and reboot:

```bash
update-grub
reboot
```

Verify IOMMU is active after reboot:

```bash
dmesg | grep -e IOMMU -e DMAR
```

### 7h. Create a Non-Root Admin User (Optional but Good Practice)

Running everything as `root` is convenient but not ideal. You can create a dedicated Proxmox user:

1. Go to **Datacenter → Users → Add**
1. Create a user (e.g., `admin@pve`)
1. Go to **Datacenter → Permissions → Add → User Permission**
1. Set the path to `/`, the user to your new user, and the role to `Administrator`

-----

## Networking Concepts: Bridges and VLANs

### Linux Bridges

A bridge (`vmbr0`) is a virtual network switch. Your physical NIC connects to it, and your VMs connect to it — making them all appear on the same LAN. This is already configured by the installer.

### VLANs (Advanced)

If you have a managed switch and want to segment your network (e.g., separate IoT devices from VMs), you can configure VLAN-aware bridges in Proxmox:

1. Go to **Node → Network**
1. Edit `vmbr0` and check **VLAN aware**
1. When creating VMs, assign them a VLAN tag under their network device settings

This is an advanced topic worth its own post, but enabling VLAN awareness on the bridge now costs nothing and saves a reconfiguration later.

-----

## Quick Reference: Key Locations in the UI

|What You Want        |Where to Find It                       |
|---------------------|---------------------------------------|
|Create a VM          |Datacenter → Node → **Create VM**      |
|Create a container   |Datacenter → Node → **Create CT**      |
|Download ISOs        |Node → local storage → **ISO Images**  |
|Download CT templates|Node → local storage → **CT Templates**|
|View resource usage  |Node → **Summary**                     |
|Manage storage       |Datacenter → **Storage**               |
|Configure backups    |Datacenter → **Backup**                |
|Shell / terminal     |Node → **Shell**                       |

-----

## What’s Next?

With Proxmox installed and configured, you’re ready to start building. Some good first projects:

- **Create your first VM** — try a lightweight Linux distro like Ubuntu Server or Debian
- **Deploy an LXC container** — great for running services like Pi-hole or Nginx with minimal overhead
- **Add a NAS for storage** — connect TrueNAS or an SMB share as a storage target in Proxmox
- **Set up Cloudflare Tunnels** — expose services securely without port-forwarding

Proxmox rewards exploration. Take it one VM at a time, make snapshots before experimenting, and you’ll have a solid homelab foundation before you know it.

-----

*Have questions or ran into a snag? Drop a comment below — happy to help troubleshoot.*