.PHONY: install
install:
	@mkdir -p ~/bin
	@[ ! -e ~/bin/passkeytool ] && ln -s "$(realpath main.sh)" ~/bin/passkeytool || true

.PHONY: install-zsh-comp
install-zsh-comp:
	@mkdir -p ~/.oh-my-zsh/custom/plugins/passkeytool
	@cp passkeytool.plugin.zsh ~/.oh-my-zsh/custom/plugins/passkeytool/passkeytool.plugin.zsh
