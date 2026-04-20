BANDIT_HOST = bandit.labs.overthewire.org
BANDIT_PORT = 2220
bandit%:
	@PASS=$$(awk -v key="bandit$*" '$$1==key {print $$2}' bandit/creds); \
	SSHPASS="$$PASS" sshpass -e ssh -p $(BANDIT_PORT) bandit$*@$(BANDIT_HOST)

LEVIATHAN_HOST = leviathan.labs.overthewire.org
LEVIATHAN_PORT = 2223
lev%:
	@PASS=$$(awk -v key="lev$*" '$$1==key {print $$2}' leviathan/creds); \
	SSHPASS="$$PASS" sshpass -e ssh -p $(LEVIATHAN_PORT) leviathan$*@$(LEVIATHAN_HOST)
