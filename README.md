# VxLan Multi Tunnel

> 🛰️ A modern, multi-point VXLAN tunnel manager with diagnostics, cleanup, and live menu — upgraded from **Lena Tunnel**.

<img src="https://github.com/RootedOne/VxLan-Multi-Tunnel/blob/main/Vx.PNG" width="631" height="266" alt="Ubuntu Tested">

---

## 📥 Installation

Run the script directly with:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/RootedOne/VxLan-Multi-Tunnel/main/Vx.sh) 
```
---

## 📦 Requirements

- ✅ Ubuntu 22.04 (tested)  
- 🧑 Root privileges (required)  
- 🐧 Linux kernel with `vxlan` + `bridge` support  

---

## 🔧 What It Does

**VxLan Multi Tunnel** is a menu-driven Bash script that creates VXLAN tunnels between multiple Linux servers (Peers A, B, C…) and a Central server (X) with DSTPORT=4789. It allows cloud VMs to securely communicate over a Layer 2 virtual overlay.

Originally forked and enhanced from **Lena Tunnel**, it adds:

- 💬 Interactive menus  
- 📊 Real-time tunnel status  
- 🧼 One-click cleanup  
- 🖥️ Multi-peer VXLAN support

---

## ✨ Features

- 🌐 Connect 2 or more peer servers to a central VXLAN node  
- 🧭 Automatic interface detection (eth0, ens3, etc.)  
- 🛠️ Menu-driven interface  
- 🧹 Cleanup mode removes all VXLAN + bridge configs  
- 🖥️ Status mode shows live tunnel + IP table  
- 🔁 Re-runnable — safely rebuilds tunnels each time  
