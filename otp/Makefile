.PHONY: install
install:
	@mkdir -p ~/bin
	@[ ! -e ~/bin/gen_otp ] && ln -s "$(realpath gen_otp.sh)" ~/bin/gen_otp || true
	@[ ! -e ~/bin/register_otp ] && ln -s "$(realpath register_otp.sh)" ~/bin/register_otp || true
	@[ ! -e ~/bin/delete_otp ] && ln -s "$(realpath delete_otp.sh)" ~/bin/delete_otp || true
	@[ ! -e ~/bin/otptool ] && ln -s "$(realpath main.sh)" ~/bin/otptool || true

.PHONY: install-zsh-comp
install-zsh-comp:
	@mkdir -p ~/.oh-my-zsh/custom/plugins/otptool
	@cp otptool.plugin.zsh ~/.oh-my-zsh/custom/plugins/otptool/otptool.plugin.zsh
