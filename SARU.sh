if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo
read -p "enter your username: " username 
useradd -m -g users -G wheel,storage,power -s /bin/bash $username 
echo
echo enter password for the user $username
passwd $username 

pacman -Syuu --noconfirm
pacman -Fy --noconfirm
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter pavucontrol feh mpv neovim zsh powerline-fonts engrampa thunderbird doas terminator git firefox papirus-icon-theme alsa-utils pulseaudio lib32-libpulse lib32-alsa-plugins
systemctl enable lightdm

echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf

cd /tmp
curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
sudo -u $username tar -xvf yay.tar.gz
cd yay
sudo -u $username makepkg -si --noconfirm

chsh -s /bin/zsh $username
cd /home/$username
curl -L http://install.ohmyz.sh | doas -u $username sh
doas -u $username git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.zsh/zsh-autosuggestions

doas -u $username yay -S --noconfirm equilux-theme

LANG="$(locale | awk -F"[_.]" '/LANG/{print tolower($2)}')"
localectl set-x11-keymap $LANG

cd /tmp
git clone https://github.com/SmellyN3rd/dotfiles
cd dotfiles

cp wallpaper.jpg /usr/share/backgrounds/xfce
sudo -u $username mkdir /home/$username/.config/
sudo -u $username mkdir /home/$username/.mozilla/

sudo -u $username cp -r config/* /home/$username/.config
sudo -u $username cp -r mozilla/* /home/$username/.mozilla
sudo -u $username cp  .zshrc /home/$username/
cp lightdm-gtk-greeter.conf /etc/lightdm/

reboot
