clear

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# this is temporarly needed to bypass sudo password when installing yay
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo
read -p "enter your username: " username 
useradd -m -g users -G wheel,storage,power -s /bin/zsh $username &> /dev/null
echo
echo enter password for the user $username
echo
passwd $username 
echo

echo -ne updating the system... 
pacman -Syu --noconfirm &> /dev/null 
echo done

echo -ne synchronizing time...
timedatectl set-ntp true &> /dev/null
echo done

echo -ne installing the desktop environment... 
pacman -S --noconfirm xorg xfce4 xfce4-artwork xfce4-whiskermenu-plugin xfce4-mpc-plugin xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-battery-plugin xfce4-clipman-plugin xfce4-datetime-plugin network-manager-applet lightdm lightdm-gtk-greeter &> /dev/null 
echo done

echo -ne installing text editors... 
pacman -S --noconfirm nano mousepad &> /dev/null 
echo done

echo -ne installing sound utilities... 
pacman -S --noconfirm alsa-utils pulseaudio lib32-libpulse lib32-alsa-plugins pavucontrol &> /dev/null 
echo done

echo -ne installing media utilities...
pacman -S --noconfirm feh mpv &> /dev/null 
echo done

echo -ne installing the file manager...
pacman -S --noconfirm thunar thunar-archive-plugin thunar-media-tags-plugin gvfs udisks2 &> /dev/null 
echo done

echo -ne installing the archive manager...
pacman -S --noconfirm engrampa &> /dev/null 
echo done

echo -ne installing the terminal...
pacman -S --noconfirm terminator &> /dev/null 
echo done

echo -ne installing the web browser...
pacman -S --noconfirm firefox &> /dev/null 
echo done

echo -ne installing the email client...
pacman -S --noconfirm thunderbird &> /dev/null 
echo done

echo -ne installing the password manager...
pacman -S --noconfirm keepassxc &> /dev/null 
echo done

echo -ne installing system utilities... 
pacman -S --noconfirm doas git &> /dev/null 
echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf
echo done

echo -ne installing yay - the AUR manager...
cd /tmp
curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
doas -u $username tar -xvf yay.tar.gz &> /dev/null
cd yay
sudo -u $username makepkg -si --noconfirm &> /dev/null 
echo done

echo -ne installing the system theme... 
doas -u $username yay -S --noconfirm equilux-theme &> /dev/null 
pacman --noconfirm -S papirus-icon-theme &> /dev/null 
echo done

echo -ne configuring the shell...
pacman -S --noconfirm zsh powerline-fonts zsh-syntax-highlighting &> /dev/null
cd /home/$username
doas -u $username curl -sL install.ohmyz.sh | doas -u $username sh &> /dev/null
doas -u $username git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.zsh/zsh-autosuggestions &> /dev/null 
echo done

echo -ne setting the keymap...
LANG="$(locale | awk -F"[_.]" '/LANG/{print tolower($2)}')"
localectl set-x11-keymap $LANG &> /dev/null 
echo done

echo -ne copying the configuration files... 
cd /tmp
git clone https://github.com/SmellyN3rd/dotfiles &> /dev/null 
cd dotfiles
cp wallpaper.jpg /usr/share/backgrounds/xfce
sudo -u $username mkdir /home/$username/.config/
sudo -u $username mkdir /home/$username/.mozilla/
sudo -u $username cp -r config/* /home/$username/.config
sudo -u $username cp -r mozilla/* /home/$username/.mozilla
sudo -u $username cp  .zshrc /home/$username/
echo include "/usr/share/nano/*.nanorc" > /home/$username/.nanorc
cp lightdm-gtk-greeter.conf /etc/lightdm/
echo done

sed -i '$ d' /etc/sudoers
systemctl enable lightdm &> /dev/null

reboot
