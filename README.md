# DESCRIPTION:
Provider for working on btrfs filesystem.   
It also deploy bash_completion script  .

# REQUIREMENTS:
* bash_completion package.
* btrfs-tools latest version from sources.

# WARNING:

You must use latest brtfs and btrfs-tools, not the one packaged by your distribution.

# ATTRIBUTES: 

# USAGE:

All the function below can be called from any recipe.  
Just include btrfs in your own recipe.

 * action :create_subvolume

 * action :delete_subvolume

 * action :create_snapshot

 * action :delete_snapshot

 * action :mount_device

 * action :umount_device

 * def btrfs_volume?(path)

 * def btrfs_disk?(path)
