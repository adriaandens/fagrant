default: fagrant.pl sshkeypair/fagrant

	/bin/cp fagrant.pl /usr/local/bin/fagrant
	/bin/chmod +x /usr/local/bin/fagrant
	/bin/cp sshkeypair/fagrant ~/.ssh/
	/bin/chmod 400 ~/.ssh/fagrant

clean:

	/bin/rm ~/.ssh/fagrant /usr/local/bin/fagrant
