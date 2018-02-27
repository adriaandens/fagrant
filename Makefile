NAME=fagrant
OS=$(shell uname -s)


default: sshkeypair/$(NAME) sshkeypair/$(NAME).pub $(NAME).pl make_vm.sh
	@echo "Checking if kit is complete..."
	@echo "Looks good."

install: $(NAME).pl sshkeypair/$(NAME)
	@echo "OS is $(OS)"

ifeq ("$(OS)","Linux")
	@echo "Installing $(NAME).pl in /usr/local/bin/"
	/bin/cp $(NAME).pl /usr/local/bin/$(NAME)
	/bin/chmod +x /usr/local/bin/$(NAME)
	@echo "Putting SSH private key in /home/$(USERNAME)/.ssh/"
	/bin/mkdir -p /home/$(USERNAME)/.ssh/
	/bin/chmod 700 /home/$(USERNAME)/.ssh/
	/bin/cp sshkeypair/$(NAME) /home/$(USERNAME)/.ssh/
	/bin/chown $(USERNAME):$(USERNAME) /home/$(USERNAME)/.ssh/$(NAME)
	/bin/chmod 400 /home/$(USERNAME)/.ssh/$(NAME)
else ifeq ("$(OS)","Darwin")
	@echo "Installing $(NAME).pl in /usr/local/bin/"
	/bin/cp $(NAME).pl /usr/local/bin/$(NAME)
	/bin/chmod +x /usr/local/bin/$(NAME)
	@echo "Putting SSH private key in /Users/$(USERNAME)/.ssh/"
	/bin/mkdir -p /Users/$(USERNAME)/.ssh/
	/bin/chmod 700 /Users/$(USERNAME)/.ssh/
	/bin/cp sshkeypair/$(NAME) /Users/$(USERNAME)/.ssh/
	/bin/chown $(USERNAME):$(USERNAME) /Users/$(USERNAME)/.ssh/$(NAME)
	/bin/chmod 400 /Users/$(USERNAME)/.ssh/$(NAME)
endif

clean:

ifeq ("$(OS)","Linux")
	/bin/rm /home/$(USERNAME)/.ssh/$(NAME) /usr/local/bin/$(NAME)
else ifeq ("$(OS)","Darwin")
	/bin/rm /Users/$(USERNAME)/.ssh/$(NAME) /usr/local/bin/$(NAME)
endif

