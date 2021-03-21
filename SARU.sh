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

pacman -S --noconfirm xfce4 xfce4-goodies terminator lightdm lightdm-gtk-greeter pavucontrol fish doas xfconf
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

doas -u $username xfconf-query -c xsettings -p /Net/ThemeName -s "Equilux"
doas -u $username xfconf-query -c xsettings -p /Net/IconThemeName -S "Paper"


