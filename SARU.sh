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
pacman -Fy
pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter pavucontrol nano vim fish engrampa thunderbird doas terminator git firefox papirus-icon-theme alsa-utils pulseaudio lib32-libpulse lib32-alsa-plugins
systemctl enable lightdm

echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf

cd /tmp
curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
sudo -u $username tar -xvf yay.tar.gz
cd yay
sudo -u $username makepkg -si --noconfirm

chsh -s /bin/fish $username
sudo -u $username mkdir --parents /home/$username/.config/fish 
sudo -u $username echo set fish_greeting >> /home/$username/.config/fish/config.fish

doas -u $username yay -S --noconfirm equilux-theme

cd /tmp
git clone https://github.com/SmellyN3rd/SARU
cd SARU/dotfiles
cp wallpaper.jpg /usr/share/backgrounds/xfce
mkdir /home/$username/.config/terminator
cp config /home/$username/.config/terminator 
cp lightdm-gtk-greeter.conf /etc/lightdm
mkdir --parents /home/$username/.config/xfce4/panel
cp whiskermenu-8.rc /home/$username/.config/xfce4/panel
mkdir --parents /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp xfce4-desktop.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp xsettings.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp xfce4-panel.xml /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
cp xfce4-clipman-actions.xml /home/$username/.config/xfce4/panel
cp helpers.rc /home/$username/.config/xfce4/
cp 00-keyboard.conf /etc/X11/xorg.conf.d
sudo -u $username cp -r mozilla /home/$username/.mozilla
cp default /home/$username/.config/xfce4/xfconf/xfce-perchannel-xml
reboot
