echo
    clear
	echo "    
     _                       _ ______                      _                                 
    | |                     | (_____ \                    | |    Configuration On CentOS                 
    | |      ___   ____ ____| |_____) ) ____ ____   ___    \ \   ____  ____ _   _ ____  ____ 
    | |     / _ \ / ___) _  | (_____ ( / _  )  _ \ / _ \    \ \ / _  )/ ___) | | / _  )/ ___)
    | |____| |_| ( (__( ( | | |     | ( (/ /| | | | |_| |____) | (/ /| |    \ V ( (/ /| |    
    |_______)___/ \____)_||_|_|     |_|\____) ||_/ \___(______/ \____)_|     \_/ \____)_|    
					    |_|	
							Coder :: Aung Thu Myint
"
	echo "    [1] System Configuration"
	echo "    [2] Configuration Repository"
	echo "    [3] Exit"
    echo
	read -p "    [#] Option : " option
    echo
	until [[ "$option" =~ ^[1-3]$ ]]; do
		echo -e "    \e[1;31m{!} Invalid Option {!}\e[0m"
		read -p "    [#] Option : " option
	done
	case "$option" in
		1)
			echo -e "\e[1;36mSystem Configuration [SELinux,Firewall,FTPService]\e[0m"
			echo
			ftp_file=/etc/vsftpd/vsftpd.conf
			selinux="$(getenforce)"

			if [ "${selinux}" = "Disabled" ];
			then
				echo "[#] SELinux Disabled"
				firewall="$(systemctl status firewalld | grep Active | awk '{print $2}')"

				if [ "${firewall}" = "inactive" ];
				then
						echo "[#] Firewall Disabled"
				else
						echo "[#] Firewall Enabled"
						while true
						do
								read -r -p "Do You Want To Stop/Disable Firewall [Y/N]" input
								case $input in
										[yY][eE][sS]|[yY])
								systemctl stop firewalld
								systemctl disable firewalld
								break
								;;
										[nN][oO]|[nN])
								break
										;;
												*)
								echo "[!] Invalid Input"
								;;
								esac
						done
				fi
			else
				echo "[#] SELinux Enabled"
				while true
				do
					read -r -p "Do You Want To Disable SELinux [Y/N]" input
					case $input in
						[yY][eE][sS]|[yY])
					cat > /etc/selinux/config <<- EOF
					SELINUX=disabled
					SELINUXTYPE=targeted
					EOF
					break
					;;
						[nN][oO]|[nN])
					break
						;;
							*)
					echo "[!] Invalid Input"
					;;
					esac
				done
				firewall="$(systemctl status firewalld | grep Active | awk '{print $2}')"

				if [ "${firewall}" = "inactive" ];
				then
						echo "[#] Firewall Disabled"
				else
						echo "[#] Firewall Enabled"
						while true
						do
								read -r -p "Do You Want To Stop/Disable Firewall [Y/N]" input
								case $input in
										[yY][eE][sS]|[yY])
								systemctl stop firewalld
								systemctl disable firewalld
								break
								;;
										[nN][oO]|[nN])
								break
										;;
												*)
								echo "[!] Invalid Input"
								;;
								esac
						done
				fi
			fi

			echo "[#] Requirement Package Installation"
			yum install vsftpd -y
			systemctl start vsftpd
			echo "[#] FTP Service Enable"
			systemctl enable vsftpd
			rm -rf $ftp_file
			cat > /etc/vsftpd/vsftpd.conf <<- EOF
			anonymous_enable=YES
			local_enable=NO
			write_enable=YES
			local_umask=022
			dirmessage_enable=YES
			xferlog_enable=YES
			connect_from_port_20=YES
			xferlog_std_format=YES
			listen=NO
			listen_ipv6=YES
			pam_service_name=vsftpd
			userlist_enable=YES
			EOF
			echo "[#] FTP Anonymous Login {Enabled}"
			echo "[#] Done"
			echo "[#] It's Works"
			read -p "Press [ENTER] to reboot ... "
			reboot
		;;
		2)
			echo -e "\e[1;36mConfiguration Repository\e[0m"
			echo
			mount /dev/sr0 /mnt
			echo "[#] Repo Fie Copying, Wait ..."
			cp -r /mnt/* /var/ftp/pub/
			mkdir /etc/yum.repos.d/backup
			mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
			ip=$(hostname --all-ip-addresses | awk '{print $1}'  )
			cat > /etc/yum.repos.d/local.repo <<- EOF
			[LocalRepo_BaseOS]
			name=BaseOS
			baseurl=ftp://$ip/pub/BaseOS/
			gpgcheck=0
			enabled=1

			[LocalRepo_AppStream]
			name=AppStream
			baseurl=ftp://$ip/pub/AppStream/
			gpgcheck=0
			enabled=1
			EOF
			yum clean all
			yum repolist all
			echo "[#] LocalRepo Configuration Is Successful."
		;;
		3)
            exit
        ;;
    esac
