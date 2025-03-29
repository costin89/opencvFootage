#!/bin/bash

echo "Starte vollständiges Openbox-Setup mit Icons, Themen und Tools..."

# System aktualisieren
sudo apt update && sudo apt upgrade -y

# Openbox + Tools
sudo apt install --no-install-recommends \
openbox xinit lightdm lightdm-gtk-greeter lxterminal pcmanfm feh nitrogen conky \
mousepad geany glade epiphany-browser xpad mate-calc onboard arandr \
git gitg gftp lxtask htop obconf lxappearance \
network-manager network-manager-gnome blueman pulseaudio pavucontrol \
trash-cli xdg-utils tightvncserver -y

# Themes & Icons
sudo apt install adwaita-icon-theme gnome-icon-theme tango-icon-theme \
gtk2-engines-murrine gtk2-engines-pixbuf -y

# Python + Dev
sudo apt install build-essential g++ python3 python3-pip -y

# Autologin aktivieren
sudo sed -i '/^\[Seat:\*\]/a autologin-user=pi\nautologin-session=openbox' /etc/lightdm/lightdm.conf

# Bluetooth-Dienst aktivieren
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Openbox-Konfiguration
mkdir -p ~/.config/openbox
cp /etc/xdg/openbox/{rc.xml,autostart} ~/.config/openbox/

# Autostart
cat > ~/.config/openbox/autostart <<EOF
nitrogen --restore &
pcmanfm &
conky &
nm-applet &
blueman-applet &
lxterminal &
EOF

# .xsession
cat > ~/.xsession <<EOF
exec openbox-session
EOF
chmod +x ~/.xsession

# Conky (alte Syntax)
mkdir -p ~/.config/conky
cat > ~/.config/conky/conky.conf <<'EOF'
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

# VNC xstartup
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<'EOF'
#!/bin/sh
xrdb $HOME/.Xresources
export XKL_XMODMAP_DISABLE=1
openbox-session &
EOF
chmod +x ~/.vnc/xstartup

# Openbox-Menü
cat > ~/.config/openbox/menu.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">

  <menu id="root-menu" label="Openbox Menü">

    <item label="Terminal (LXTerminal)">
      <action name="Execute"><command>lxterminal</command></action>
    </item>

    <separator/>

    <item label="Task-Manager (LXTASK)">
      <action name="Execute"><command>sh -c 'lxtask'</command></action>
    </item>

    <separator/>

    <item label="Papierkorb leeren (Trash)">
      <action name="Execute"><command>lxterminal -e trash-empty</command></action>
    </item>

    <menu id="system" label="System">
      <item label="Dateimanager (PCManFM)">
        <action name="Execute"><command>pcmanfm</command></action>
      </item>
      <item label="Papierkorb öffnen">
        <action name="Execute"><command>pcmanfm trash://</command></action>
      </item>
      <item label="Audio Einstellungen (PulseAudio)">
        <action name="Execute"><command>pavucontrol</command></action>
      </item>
      <item label="Bluetooth Verwaltung (Blueman)">
        <action name="Execute"><command>blueman-manager</command></action>
      </item>
      <item label="Netzwerk Einstellungen (nm-connection-editor)">
        <action name="Execute"><command>nm-connection-editor</command></action>
      </item>
      <item label="Prozessanzeige (htop)">
        <action name="Execute"><command>lxterminal -e htop</command></action>
      </item>
      <item label="Monitor (Bildschirm drehen)">
        <action name="Execute"><command>sh -c 'arandr'</command></action>
      </item>
    </menu>

    <menu id="internet" label="Internet">
      <item label="Webbrowser (Epiphany)">
        <action name="Execute"><command>sh -c 'epiphany-browser'</command></action>
      </item>
      <item label="FTP-Client (gFTP)">
        <action name="Execute"><command>sh -c 'gftp'</command></action>
      </item>
    </menu>

    <menu id="entwicklung" label="Entwicklung">
      <item label="Geany Editor">
        <action name="Execute"><command>geany</command></action>
      </item>
      <item label="GTK Designer (Glade)">
        <action name="Execute"><command>glade</command></action>
      </item>
      <item label="Git-Viewer (Gitg)">
        <action name="Execute"><command>sh -c 'gitg'</command></action>
      </item>
    </menu>

    <menu id="extras" label="Extras & Zubehör">
      <item label="Texteditor (Mousepad)">
        <action name="Execute"><command>mousepad</command></action>
      </item>
      <item label="Taschenrechner (Mate Calc)">
        <action name="Execute"><command>sh -c 'mate-calc'</command></action>
      </item>
      <item label="Notizen (Xpad)">
        <action name="Execute"><command>sh -c 'xpad'</command></action>
      </item>
      <item label="Virtuelle Tastatur (Onboard)">
        <action name="Execute"><command>sh -c 'onboard'</command></action>
      </item>
      <item label="Bildbetrachter (feh)">
        <action name="Execute"><command>feh</command></action>
      </item>
      <item label="Wallpaper ändern (Nitrogen)">
        <action name="Execute"><command>nitrogen</command></action>
      </item>
    </menu>

    <menu id="vnc" label="VNC">
      <item label="VNC-Server starten (:1)">
        <action name="Execute"><command>lxterminal -e 'vncserver :1'</command></action>
      </item>
      <item label="VNC-Server stoppen (:1)">
        <action name="Execute"><command>lxterminal -e 'vncserver -kill :1'</command></action>
      </item>
    </menu>

    <menu id="helfer" label="Helfer">
      <item label="System aktualisieren">
        <action name="Execute"><command>lxterminal -e 'sudo apt update && sudo apt upgrade -y'</command></action>
      </item>
      <item label="Python + Pip aktualisieren">
        <action name="Execute"><command>lxterminal -e 'sudo pip3 install --upgrade pip && sudo apt install --only-upgrade python3'</command></action>
      </item>
      <item label="Monitor drehen: normal">
        <action name="Execute"><command>lxterminal -e 'xrandr --output HDMI-1 --rotate normal'</command></action>
      </item>
      <item label="Monitor drehen: rechts">
        <action name="Execute"><command>lxterminal -e 'xrandr --output HDMI-1 --rotate right'</command></action>
      </item>
      <item label="Monitor drehen: 180°">
        <action name="Execute"><command>lxterminal -e 'xrandr --output HDMI-1 --rotate inverted'</command></action>
      </item>
      <item label="Monitor drehen: links">
        <action name="Execute"><command>lxterminal -e 'xrandr --output HDMI-1 --rotate left'</command></action>
      </item>
    </menu>

    <menu id="obmenu" label="obmenu">
      <item label="Menü neu laden">
        <action name="Execute"><command>openbox --reconfigure</command></action>
      </item>
      <item label="Menü bearbeiten (Mousepad)">
        <action name="Execute"><command>mousepad ~/.config/openbox/menu.xml</command></action>
      </item>
      <item label="Openbox Einstellungen (obconf)">
        <action name="Execute"><command>sh -c 'obconf'</command></action>
      </item>
      <item label="Design & Icons (LXAppearance)">
        <action name="Execute"><command>lxappearance</command></action>
      </item>
    </menu>

    <separator/>

    <menu id="session" label="Systemsteuerung">
      <item label="Neustart">
        <action name="Execute"><command>systemctl reboot</command></action>
      </item>
      <item label="Herunterfahren">
        <action name="Execute"><command>systemctl poweroff</command></action>
      </item>
      <item label="Abmelden">
        <action name="Exit"/>
      </item>
    </menu>

  </menu>

</openbox_menu>
EOF

echo "Setup abgeschlossen!"
echo "Menü neu laden: openbox --reconfigure"
echo "Icons & Design ändern: lxappearance"
