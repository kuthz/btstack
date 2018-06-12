# Bittorrent docker stack

Repository that contains docker-compose file with docker images to seed


## Instruction and Usage
All traffic go through the openvpn container. If the container is not running no network access is available for other containers

The stack use docker-compose, so usage show docker-compose way

### OpenVPN

#### Usage

```
  volumes:
    - <path to .opvn folder>:/etc/openvpn/profile/
  environment:
    - OPENVPN_CONFIG=<ovpn file to use>
    - LOCAL_NETWORK=<local network ip address range>
    - OPENVPN_OPTS=<openvpn extra options>
```

If the .ovpn don't include the credentials in it, you can add a file `.credentials` in the `<path to .opvn folder>`
The file must contains these information
```
<username>
<password>
```

When the docker will start the file will be use for authentication

#### Parameters


* `<path to .opvn folder>` - folder on the host where the .opvn file are located
* `<ovpn file to use>` - .opvn file to use, no need to specified the .opvn extension
* `<local network ip address range>` - specify this env variable to give access to local network, format 192.168.1.1/24
* `<openvpn extra options>` - specify any extra openvpn options you want to add


### Transmission

See https://github.com/linuxserver/docker-transmission/

### Jackett

See https://github.com/linuxserver/docker-jackett/

### Sonarr

See https://github.com/linuxserver/docker-sonarr/

### Radarr

See https://github.com/linuxserver/docker-radarr/


## Mounting Samba/cifs V3 remote volume on the host to use with container

This procedure is tested with a Synology DSM 6.X.
Verified that SMB V3 is activated in the configuration
```
Control Panel, File Services, Advanced settings
Set Maximum SMB protocol to SMB3
```

Create a samba .smbcredential file in root home directory
```
username=<username>
password=<password>
```

Secure the file with `chmod 700 .smbcredentials`


Modify the `/etc/fstab`

```
//<remote mount>  <local mount>  cifs  credentials=<smbcredentials>,cache=none,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777  0  0
```

* `<remote mount>` - Remote samba share to mount for example 192.168.1.1/video
* `<local mount>` - Local folder to mount /home/media/mount/video
* `<smbcredentials>` - Location of the .smbcredentials file