VENV=.venv
PY=$(VENV)/bin/python3
PIP=$(VENV)/bin/pip
ANSIBLE=$(VENV)/bin/ansible-playbook

all: add_peer

$(VENV):
    @echo "[+] Creating virtual environment..."
    @python3 -m venv $(VENV)

.PHONY: check
check:
    @echo "[+] Checking system dependencies..."
    @command -v python3 >/dev/null || { echo "[-] Missing python3. Install it"; exit 1; }
    @python3 -c "import ensurepip" 2>/dev/null || { echo "[-] Missing python3-venv. Install: sudo apt install -y python3-venv"; exit 1; }
    @command -v sshpass >/dev/null || { echo "[-] Missing sshpass. Install: sudo apt install -y sshpass"; exit 1; }
    @command -v wg >/dev/null || { echo "[-] Missing wireguard-tools (wg). Install: sudo apt install -y wireguard-tools"; exit 1; }
    @command -v resolvconf >/dev/null || echo "[!] Warning: resolvconf not found; wg-quick may warn. Install: sudo apt install -y resolvconf"

install: $(VENV)
	@echo "[+] Installing Ansible..."
	@$(PIP) install --upgrade pip >/dev/null
	@if [ -f requirements.txt ]; then \
		$(PIP) install -r requirements.txt >/dev/null; \
	else \
		$(PIP) install ansible >/dev/null; \
	fi
	@echo "[+] Ansible installed."

add_peer: check install
    @echo "[+] Running WireGuard peer provisioning playbook..."
    @$(ANSIBLE) add_peer.yaml

# Back-compat alias
run: add_peer

remove_peer: check install
    @echo "[+] Removing local wg0 and remote MikroTik peer (if reachable)..."
    @$(ANSIBLE) remove_peer.yaml

.PHONY: bootstrap setup

bootstrap:
	@echo "[+] Installing system dependencies (requires sudo)..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && \
		sudo apt-get install -y python3-venv sshpass wireguard-tools resolvconf; \
	elif command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y python3-virtualenv sshpass wireguard-tools openresolv; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y python3-virtualenv sshpass wireguard-tools openresolv; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -Sy --noconfirm python-virtualenv sshpass wireguard-tools openresolv; \
	else \
		echo "[-] Unsupported package manager. Please install: python3-venv sshpass wireguard-tools resolvconf"; \
		exit 1; \
	fi
	@echo "[+] System dependencies installed."

setup: bootstrap install
	@echo "[+] Python environment ready."

# Back-compat alias
remove: remove_peer

clean:
	rm -rf $(VENV)
