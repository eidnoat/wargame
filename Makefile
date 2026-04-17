BANDIT_HOST = bandit.labs.overthewire.org
BANDIT_PORT = 2220

bandit%:
	@PASS=$$(awk -v key="bandit$*" '$$1==key {print $$2}' bandit/creds); \
	SSHPASS="$$PASS" sshpass -e ssh -p $(BANDIT_PORT) bandit$*@$(BANDIT_HOST)