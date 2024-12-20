mkdir /mnt
mount /dev/nvme0n1p4 /mnt

# Create backup for old @home and restore it
if [[ -e /mnt/@home ]]; then
    mkdir -p /mnt/home_backups
    timestamp=$(date "+%Y-%m-%-d_%H:%M:%S")
    btrfs subvolume snapshot /mnt/@home /mnt/home_backups/@home-$timestamp
    btrfs subvolume delete /mnt/@home
fi

# Delete backups for @home that are older than 30 days
for i in $(find /mnt/home_backups/ -maxdepth 1 -mtime +30); do
    btrfs subvolume delete "$i"
done

# Create a new clean @home
btrfs subvolume create /mnt/@home
mkdir -p /mnt/@home/unlsycn
chown unlsycn:users /mnt/@home/unlsycn
umount /mnt
