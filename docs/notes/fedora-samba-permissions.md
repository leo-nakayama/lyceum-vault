
# Fedora/Kubuntu Samba Permissions Cheatsheet

## Server (SELinux + permissions)
```bash
# Label share dir
sudo semanage fcontext -a -t samba_share_t "/srv/share(/.*)?"
sudo restorecon -Rv /srv/share

# Group + ACLs
sudo chgrp -R sambausers /srv/share
sudo chmod -R 2775 /srv/share
sudo setfacl -R -m g:sambausers:rwx /srv/share
```

## smb.conf (snippet)
```ini
[share]
   path = /srv/share
   browsable = yes
   writable = yes
   valid users = @sambausers
   force group = sambausers
   create mask = 0664
   directory mask = 2775
```

## Client mount (/etc/fstab)
```
# //server/share  /mnt/share  cifs  credentials=/etc/samba/creds,vers=3.0,iocharset=utf8,uid=<user>,gid=<group>,file_mode=0664,dir_mode=0775  0  0
```
