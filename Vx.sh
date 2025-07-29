#!/bin/bash
set -euo pipefail

VNI=88
DSTPORT=4789
BRIDGE=br0
VXIF="vxlan${VNI}"

# Detect underlay interface
IFACE=$(ip route get 1.1.1.1 | awk '{print $5; exit}')

# Menu
clear
echo "=========================="
echo "  VXLAN Setup Menu"
echo "=========================="
echo "1. Peer Server (A, B, C, D, E...)"
echo "2. Central Server (X)"
echo "3. Show VXLAN Tunnel Info"
echo "4. Cleanup All VXLAN Configurations"
echo "--------------------------"
read -rp "Choose an option (1-4): " choice

case "$choice" in
  1)
    read -rp "Enter this server's PUBLIC IP: " UNDERLAY_IP
    read -rp "Enter Central Server X's PUBLIC IP: " CENTRAL_IP
    read -rp "Enter this server's VXLAN overlay IP (e.g. 30.0.0.X/24): " OVERLAY_IP

    # Cleanup
    ip link del "$VXIF" 2>/dev/null || true
    ip link del "$BRIDGE" 2>/dev/null || true

    # Setup
    ip link add name "$BRIDGE" type bridge
    ip link set "$BRIDGE" up
    ip link add "$VXIF" type vxlan id $VNI dev "$IFACE" local "$UNDERLAY_IP" remote "$CENTRAL_IP" dstport $DSTPORT nolearning
    ip link set "$VXIF" up
    ip link set "$VXIF" master "$BRIDGE"
    ip addr add "$OVERLAY_IP" dev "$BRIDGE"
    echo "[DONE] Peer connected to central server $CENTRAL_IP with overlay $OVERLAY_IP"
    ;;
  2)
    read -rp "Enter this server's PUBLIC IP (Central Server X): " UNDERLAY_IP
    read -rp "Enter number of peer servers to connect: " COUNT
    PEERS=()
    for ((i=1; i<=COUNT; i++)); do
      read -rp "Enter public IP of Peer #$i: " peer
      PEERS+=("$peer")
    done
    read -rp "Enter Central overlay IP (e.g. 30.0.0.1/24): " OVERLAY_IP

    # Cleanup
    ip link del "$VXIF" 2>/dev/null || true
    ip link del "$BRIDGE" 2>/dev/null || true

    # Setup
    ip link add name "$BRIDGE" type bridge
    ip link set "$BRIDGE" up
    ip link add "$VXIF" type vxlan id $VNI dev "$IFACE" dstport $DSTPORT nolearning
    ip link set "$VXIF" up
    ip link set "$VXIF" master "$BRIDGE"
    for peer in "${PEERS[@]}"; do
      bridge fdb append 00:00:00:00:00:00 dev "$VXIF" dst "$peer"
    done
    ip addr add "$OVERLAY_IP" dev "$BRIDGE"
    echo "[DONE] Central VXLAN bridge ready on $OVERLAY_IP connected to peers: ${PEERS[*]}"
    ;;
  3)
    echo
    echo "Current VXLAN Tunnel Status"
    echo "============================"
    printf "%-15s %-20s %-15s\n" "Interface" "Remote IP" "Bridge IP"
    echo "-----------------------------------------------------"

    # Fetch overlay IP
    overlay_ip=$(ip -4 addr show dev "$BRIDGE" | awk '/inet / {print $2}')
    # Fetch remote IPs from FDB entries (only IPv4)
    mapfile -t remotes < <(bridge fdb show dev "$VXIF" | grep -oE 'dst [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}')

    for remote in "${remotes[@]}"; do
      printf "%-15s %-20s %-15s\n" "$VXIF" "$remote" "$overlay_ip"
    done
    echo
    ;;
  4)
    echo
    echo "Cleaning up VXLAN configuration..."
    ip link del "$VXIF" 2>/dev/null || true
    ip link del "$BRIDGE" 2>/dev/null || true
    echo "[DONE] All VXLAN and bridge interfaces removed."
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac
