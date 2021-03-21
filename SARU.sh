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

pacman -Syuu
pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter pavucontrol fish doas terminator git firefox
systemctl enable lightdm

echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf

cd /tmp
curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
sudo -u $username tar -xvf yay.tar.gz
cd yay
sudo -u $username makepkg -si --noconfirm

chsh -s /bin/fish $username
mkdir --parents /home/$username/.config/fish 
echo set fish_greeting >> /home/$username/.config/fish/config.fish

doas -u $username yay -S --noconfirm paper-icon-theme equilux-theme

cd /tmp
git clone https://github.com/SmellyN3rd/SARU
cd SARU/dotfiles
cp --parents wallpaper.jpg /usr/share/backgrounds/xfce
cp --parents config /home/$username/.config/terminator 
cp --parents lightdm-gtk-greeter.conf /etc/lightdm
cp --parents whiskermenu-8.rc /home/$username/.config/xfce4/panel
cp --parents xfce4-desktop.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp --parents xsettings.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp --parents xfce4-panel.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml





