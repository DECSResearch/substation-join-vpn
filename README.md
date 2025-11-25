# join_vpn (Simple Usage)

Quick, no‑frills steps to add or remove a WireGuard peer on a MikroTik router.

## Prereqs
- Linux host with:
  - `sshpass`, `wireguard-tools` (`wg`, `wg-quick`), and `resolvconf`
  - Python 3 and `make`

## Add a peer
- Command: `make add_peer`
- What happens:
  - Creates `.venv` and installs Python deps from `requirements.txt`
  - Prompts for MikroTik host/port/user/password (has sensible defaults)
  - Auto-detects the WireGuard interface on the router
  - Generates a client keypair, adds the peer on the router
  - Writes `/etc/wireguard/wg0.conf` and brings up `wg0`
  - Prints a brief status (route + ping check)

## Remove a peer
- Command: `make remove_peer`
- What happens:
  - Reads `/etc/wireguard/wg0.conf` to get your `Address`
  - If the router is reachable, removes that peer on the router
  - Brings `wg0` down and deletes `/etc/wireguard/wg0.conf`
  - If the config file is missing, it will ask for the allowed‑address

## Common notes
- Default config path: `/etc/wireguard/wg0.conf`
- Bring up manually (optional): `sudo wg-quick up wg0`
- Show status: `sudo wg show` and `ip route | grep 10.8.0.0/24`
- If DNS is flaky, use the router’s public IP instead of hostname.

That’s it. Keep it simple: `make add_peer` to add, `make remove_peer` to remove.

