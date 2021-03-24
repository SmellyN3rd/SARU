clear

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo permit :wheel nopass > /etc/doas.conf
echo permit root nopass keepenv> /etc/doas.conf

# this is temporarly needed to bypass sudo when installing yay
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

echo
read -p "enter your username: " username 
useradd -m -g users -G wheel,storage,power -s /bin/bash $username 
echo
echo enter password for the user $username
echo
passwd $username 
echo

echo -ne synchronizing time...
timedatectl set-ntp true &> /dev/null
echo done

echo -ne refreshing pacman databases... 
pacman -Fy --noconfirm  &> /dev/null 
pacman -Syy --noconfirm  &> /dev/null 
echo done

echo -ne updating the system... 
pacman -Syuu --noconfirm &> /dev/null 
echo done

echo -ne installing the display server... 
pacman -S --noconfirm xorg &> /dev/null 
echo done

echo -ne installing the desktop environment... 
pacman -S --noconfirm xfce4 xfce4-goodies network-manager-applet lightdm lightdm-gtk-greeter &> /dev/null 
echo done

echo -ne installing sound utilities... 
pacman -S --noconfirm alsa-utils pulseaudio lib32-libpulse lib32-alsa-plugins pavucontrol &> /dev/null 
echo done

echo -ne installing yay - the AUR manager...
cd /tmp
curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
sudo -u $username tar -xvf yay.tar.gz &> /dev/null
cd yay
sudo -u $username makepkg -si --noconfirm &> /dev/null 
echo done

echo -ne installing other programs... 
pacman -S --noconfirm feh mpv neovim zsh powerline-fonts engrampa thunderbird doas terminator git firefox &> /dev/null 
echo done

echo -ne installing the system theme... 
doas -u $username yay -S --noconfirm equilux-theme &> /dev/null 
pacman --noconfirm -S papirus-icon-theme &> /dev/null 
echo done

echo -ne configuring the shell...
cd /home/$username
sudo -u $username curl -sL install.ohmyz.sh | sh &> /dev/null
pacman --noconfirm -S zsh-syntax-highlighting &> /dev/null
doas -u $username git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.zsh/zsh-autosuggestions &> /dev/null 
chsh -s /bin/zsh $username &> /dev/null
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
cp lightdm-gtk-greeter.conf /etc/lightdm/
echo done

sed -i '$ d' /etc/sudoers
systemctl enable lightdm &> /dev/null

reboot
