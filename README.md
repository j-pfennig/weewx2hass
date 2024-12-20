'weewx2hass' is an all-in-one tool that uses 'sqlite3' and 'mosquitto_pub' to
poll the SQLite data-base of weewx and to send extracted data to a MQtt broker.
The MQtt uses JSON data as its payload so that it can be interpreted easily by
'Home Assistant'. The tool also generates the required sensor definitions in
Yaml format. Finally a systemd service file can be generated.

Load the full version from github (everything is in one bash script):

        wget github.com/j-pfennig/weewx2hass/blob/main/weewx2hass 

The is a simplified non-configurable version of this script that may help you
to understand how it works:

        wget github.com/j-pfennig/weewx2hass/blob/main/weewx2hass-temp-only

This script uses an embedded version of 'mini-bash-lib'. This is not relevant
for using it, but for the curious:

        https://github.com/j-pfennig/mini-bash-lib

Try these commands to make it work:

        weewx2hass --help                                   # display a help page

        weewx2hass --show config /etc/default/weewx2hass    # make config template
        editor /etc/default/weewx2hass                      # edit configuration

        weewx2hass --show yaml                              # sensor configuration
        weewx2hass --show mqtt                              # mosquitto configuration
                                                            # create service file ...
        weewx2hass --show systemd /etc/systemd/system/weewx2hass.service

        apt install sqlite3 mosquitto mosquitto-clients     # install dependencies

