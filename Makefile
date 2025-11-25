VENV=.venv
PY=$(VENV)/bin/python3
PIP=$(VENV)/bin/pip
ANSIBLE=$(VENV)/bin/ansible-playbook

all: add_peer

$(VENV):
	@echo "[+] Creating virtual environment..."
	@python3 -m venv $(VENV)

install: $(VENV)
	@echo "[+] Installing Ansible..."
	@$(PIP) install --upgrade pip >/dev/null
	@if [ -f requirements.txt ]; then \
		$(PIP) install -r requirements.txt >/dev/null; \
	else \
		$(PIP) install ansible >/dev/null; \
	fi
	@echo "[+] Ansible installed."

add_peer: install
	@echo "[+] Running WireGuard peer provisioning playbook..."
	@$(ANSIBLE) add_peer.yaml

# Back-compat alias
run: add_peer

remove_peer: install
	@echo "[+] Removing local wg0 and remote MikroTik peer (if reachable)..."
	@$(ANSIBLE) remove_peer.yaml

# Back-compat alias
remove: remove_peer

clean:
	rm -rf $(VENV)
