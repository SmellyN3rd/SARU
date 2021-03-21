if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -p "enter your username: " username 
useradd -m -g users -G wheel,storage,power -s /bin/bash $username 
echo enter password for the user $username
passwd $username 

pacman -S  --noconfirm xfce4 xfce4-goodies terminator lightdm lightdm-gtk-greeter pavucontrol fish doas
systemctl enable lightdm

echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf

sudo -u $username cd /tmp && git clone https://aur.archlinux.org/yay.git  && cd yay && makepkg -si

chsh -s /bin/fish $username
echo set fish_greeting >> /home/$username/.config/fish/config.fish

doas -u $username yay -S --noconfirm paper-icon-theme Equilux-theme

doas -u $username xfconf-query -c xsettings -p /Net/ThemeName -s "Equilux"
doas -u $username xfconf-query -c xsettings -p /Net/IconThemeName -S "Paper"


