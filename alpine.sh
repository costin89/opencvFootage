#!/bin/sh

echo " Starte Openbox-Setup unter Alpine Linux..."

# System aktualisieren
sudo apk update && sudo apk upgrade

# Benutzer 'admin' erstellen, falls nicht vorhanden
adduser -D admin
echo "admin:admin" | chpasswd
addgroup admin wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# X, Openbox und Tools
sudo apk add openbox xinit lightdm lightdm-gtk-greeter \
lxterminal pcmanfm feh conky mousepad geany arandr \
git gftp lxtask htop obconf lxappearance \
networkmanager network-manager-applet blueman \
pulseaudio pulsemixer xdg-utils tightvnc

# Themes & Icons
sudo apk add adwaita-icon-theme gnome-icon-theme tango-icon-theme \
gtk-engine-murrine gtk+2.0-engine-pixbuf

# LightDM konfigurieren (Autologin für admin)
sudo sed -i '/^\[Seat:\*\]/a autologin-user=admin\nautologin-session=openbox' /etc/lightdm/lightdm.conf

# Autostart NetworkManager & Bluetooth
sudo rc-update add NetworkManager
sudo rc-service NetworkManager start

sudo rc-update add bluetooth
sudo rc-service bluetooth start

# Autostart LightDM
sudo rc-update add lightdm
sudo rc-service lightdm start

# Konfigurationsdateien für admin einrichten
su - admin -c 'mkdir -p ~/.config/openbox ~/.config/conky ~/.vnc'

# Openbox Default Config kopieren
su - admin -c 'cp /etc/xdg/openbox/{rc.xml,autostart} ~/.config/openbox/'

# Autostart-Datei schreiben
cat > /home/admin/.config/openbox/autostart <<EOF
nitrogen --restore &
pcmanfm &
conky &
nm-applet &
blueman-applet &
lxterminal &
EOF

# .xsession für X
cat > /home/admin/.xsession <<EOF
exec openbox-session
EOF
chmod +x /home/admin/.xsession

# Conky Config
cat > /home/admin/.config/conky/conky.conf <<'EOF'
background yes
use_xft yes
xftfont monospace:size=10
update_interval 1.0
total_run_times 0
own_window yes
own_window_type desktop
own_window_transparent yes
double_buffer yes
minimum_size 200 0
maximum_width 250
draw_shades no
alignment top_right
gap_x 20
gap_y 40
cpu_avg_samples 2
net_avg_samples 2
override_utf8_locale yes

TEXT
${time %A, %d. %B %Y}
${time %H:%M:%S}

Uptime: ${uptime}
CPU: ${cpu}%  
RAM: ${mem} / ${memmax}
Disk: ${fs_used /} / ${fs_size /}

Down: ${downspeedf wlan0} kB/s  
Up:   ${upspeedf wlan0} kB/s
IP: ${addr wlan0}
EOF

# VNC-Startskript
cat > /home/admin/.vnc/xstartup <<'EOF'
#!/bin/sh
xrdb $HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
openbox-session &
EOF
chmod +x /home/admin/.vnc/xstartup

# Menü-Datei schreiben
cat > /home/admin/.config/openbox/menu.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">

  <menu id="root-menu" label="Openbox Menü">

    <item label="Terminal (LXTerminal)">
      <action name="Execute"><command>lxterminal</command></action>
    </item>

    <separator/>

    <item label="Dateimanager (PCManFM)">
      <action name="Execute"><command>pcmanfm</command></action>
    </item>

    <item label="Wallpaper ändern (Nitrogen)">
      <action name="Execute"><command>nitrogen</command></action>
    </item>

    <item label="Netzwerk Einstellungen">
      <action name="Execute"><command>nm-connection-editor</command></action>
    </item>

    <item label="Bluetooth">
      <action name="Execute"><command>blueman-manager</command></action>
    </item>

    <item label="Audio Einstellungen">
      <action name="Execute"><command>pulsemixer</command></action>
    </item>

    <item label="Task-Manager">
      <action name="Execute"><command>lxtask</command></action>
    </item>

    <item label="Prozesse (htop)">
      <action name="Execute"><command>lxterminal -e htop</command></action>
    </item>

    <item label="Editor (Mousepad)">
      <action name="Execute"><command>mousepad</command></action>
    </item>

    <item label="Editor (Geany)">
      <action name="Execute"><command>geany</command></action>
    </item>

    <item label="FTP-Client (gFTP)">
      <action name="Execute"><command>gftp</command></action>
    </item>

    <item label="Bildschirm (ARandR)">
      <action name="Execute"><command>arandr</command></action>
    </item>

    <item label="VNC-Server starten">
      <action name="Execute"><command>lxterminal -e 'vncserver :1'</command></action>
    </item>

    <item label="VNC-Server stoppen">
      <action name="Execute"><command>lxterminal -e 'vncserver -kill :1'</command></action>
    </item>

    <separator/>

    <item label="Menü neu laden">
      <action name="Execute"><command>openbox --reconfigure</command></action>
    </item>

    <item label="Design & Icons (LXAppearance)">
      <action name="Execute"><command>lxappearance</command></action>
    </item>

    <separator/>

    <item label="Neustart">
      <action name="Execute"><command>reboot</command></action>
    </item>

    <item label="Herunterfahren">
      <action name="Execute"><command>poweroff</command></action>
    </item>

  </menu>

</openbox_menu>
EOF

# Rechte korrigieren
chown -R admin:admin /home/admin

echo "Openbox-Setup abgeschlossen!"
echo " Benutzer: admin / Passwort: admin"
echo " Menü neu laden: openbox --reconfigure"
