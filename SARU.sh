if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

read -p "enter your username: " username 
useradd -m -g users -G wheel,storage,power -s /bin/bash $username 
echo enter password for the user $username
passwd $username 

pacman -S  --noconfirm --needed git base-devel

pacman -S  --noconfirm xfce4 xfce4-goodies terminator lightdm lightdm-gtk-greeter pavucontrol fish doas

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo permit :wheel > /etc/doas.conf
echo permit nopass keepenv root >> /etc/doas.conf

chsh -s /bin/fish $username

doas -u $username yay -S --noconfirm paper-icon-theme Equilux-theme

doas -u $username xfconf-query -c xsettings -p /Net/ThemeName -s "Equilux"
doas -u $username xfconf-query -c xsettings -p /Net/IconThemeName -S "Paper"

curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf install agnoster
echo set fish_greeting >> /home/$username/.config/fish/config.fish

