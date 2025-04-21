**Overview**

Here we habe two tools, 'weewx2hass' and 'weewx2watch', implemented as bash
scripts. Each can be used indendently but they fit into a larger context:

1. A HTML based day-time-clock with temperatures display
2. Importing weather data from a MQtt broker
3. Publishing data from HomeAssistant via MQtt (optional)
4. Importing data from a WeeWx weather stattion into HomeAssistant
5. Building an appliance using centaurisoho

The scripts use mini-bash-lib which can either be shared, e.g. loaded by the
scripts sharing it, or it can be embedded to make scripts stand-alone. The
release sources contain both versions, in a production environment only a
sub-set is needed. For the shared version these files are needed:

        ├── mini-bash-lib
        │   ├── _mini_bash_lib          # proxy to load mini-bash-lib
        │   └── mini-bash-lib.p         # packed library source
        ├── shared
        │   ├── _mini_bash_lib -> ../mini-bash-lib/_mini_bash_lib
        │   ├── weewx2hass
        │   └── weewx2watch

And for the stand-alone version only two files are used:

        └── standalone
            ├── weewx2hass
            └── weewx2watch

For more details see:

- https://github.com/j-pfennig/mini-bash-lib

**To be mentioned: centaurisoho and centauritools**

The weewx tools are part of a larger context, but can be used independently:

1. centaurisoho: a Debian installer and configuration repository
2. centauritools: a collection of system administration tools
3. centauri-bash-lib: framework used to implement (1) and (2) 

For more details see:

- https://github.com/j-pfennig/centaurisoho
- https://github.com/j-pfennig/centauri-bash-lib

**weewx2hass to publish WeeWx data via MQtt**

'weewx2hass' is an all-in-one tool that uses 'sqlite3' and 'mosquitto_pub' to
poll the SQLite data-base of weewx and to send extracted data to a MQtt broker.
The MQtt uses JSON data as its payload so that it can be interpreted easily by
'Home Assistant'. The tool also generates the required sensor definitions in
Yaml format. Finally a systemd service file can be generated.

Load the full version from github (everything is in one bash script):

        wget raw.githubusercontent.com/j-pfennig/weewx2hass/refs/heads/main/weewx2hass

The is a simplified non-configurable version of this script that may help you
to understand how it works:

        wget raw.githubusercontent.com/j-pfennig/weewx2hass/refs/heads/main/weewx2hass-temp-only

Try these commands to setup weewx data import for HomeAssistant:

        weewx2hass --help                                   # display a help page

        weewx2hass --show config /etc/default/weewx2hass    # make config template
        editor /etc/default/weewx2hass                      # edit configuration

        weewx2hass --show yaml                              # sensor configuration
        weewx2hass --show mqtt                              # mosquitto configuration
                                                            # create service file ...
        weewx2hass --show systemd /etc/systemd/system/weewx2hass.service

        apt install sqlite3 mosquitto mosquitto-clients     # install dependencies

**weewx2watch monitor and weather-station day-time-clock**

'weewx2watch' is a monitor tool and a simple ASCII-art or HTML digital clock
that can show inside/outside temperatures. See 'weewx2watch --help' for details.
The following scenarios will briefly described below:

1. Monitor MQtt data
2. Write MQtt data to a File (web server)
3. Mock-up weather-station day-time-clock
4. Stand alone usage as weather-station day-time-clock
5. Integration with centauriclock (centauri-tools only)

*weewx2watch stand alone usage as weather-station day-time-clock*

Run as user 'weewx', create a configuration folder:

        sudo -i -u weewx
        ln -s <source-folder>/weewx2show .
        ./weewx2show --base=- --host=<mqtt-host>

To use a web server to provide data use --url instead of host:

        ./weewx2show --base=- --url=<http-url>

Folder '.local/weewx2show' should now contain this data:

        weewx2show.bash             # script to launch a browser
        weewx2show.html             # html code
        weewx2show.js               # weather data or web url

*Integration with centauriclock (centauri-tools only)*

Run as user 'clock', create a configuration folder:

        sudo -i -u clock
        centauriclock --base=-
        ln -s <source-folder>/weewx2show .
        ./weewx2show --base=- --host=<mqtt-host>

Folder '.local/centauriclock' should now contain this data:

        centauriclock.bash          # script to launch weewx2show
        centauriclock.html          # html code
        centauriclock.js            # weather data

To use a web server to provide data use --url instead of host:

        ./weewx2show --base=- --url=<http-url>

Folder '.local/centauriclock' should now contain this data:

        centauriclock.html          # html code
        centauriclock.js            # web url

**end**
