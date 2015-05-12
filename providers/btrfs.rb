def whyrun_supported?
  true
end

use_inline_resources 


action :create_subvolume do
  unless @new_resource.exists
    pathdir=new_resource.pathdir
    name=new_resource.name
    converge_by "creating btrfs-subvolume #{pathdir}/#{name}" do
      Chef::Application.fatal!("Provider BTRFS - #{pathdir} is not a BTRFS volume") unless btrfs_volume?("#{pathdir}") == true
      execute "create subvolume #{pathdir}/#{name}" do
        command "btrfs subvolume create #{pathdir}/#{name}"
        not_if { ::File.exists?("#{pathdir}/#{name}")}
        timeout 10
      end
    end
  end
end

action :delete_subvolume do
  unless @new_resource.exists
    pathdir = new_resource.pathdir
    name = new_resource.name
    converge_by "deleting btrfs-subvolume #{name}" do
      Chef::Application.fatal!("Provider BTRFS - #{pathdir} is not a BTRFS volume") unless btrfs_volume?("#{pathdir}") == true
      execute "create subvolume #{pathdir}/#{name}" do
        command "btrfs subvolume delete #{pathdir}/#{name}"
        not_if { !::File.exists?("#{pathdir}/#{name}")}
        timeout 10
      end
    end
  end
end

action :create_snapshot do
  unless @new_resource.exists
    pathdir = new_resource.pathdir
    name = new_resource.name
    snap_pathdir = new_resource.snap_pathdir
    snap_name = new_resource.snap_name
    if ( new_resource.snap_mode )
      snap_mode = new_resource.snap_mode
    else 
      snap_mode = ""
    end
    converge_by "creatinh snapshot for #{name} on #{snap_name}" do
      Chef::Application.fatal!("Provider BTRFS - #{pathdir} is not a BTRFS volume") unless btrfs_volume?("#{pathdir}") == true
      Chef::Application.fatal!("Provider BTRFS - #{snap_pathdir} is not a BTRFS volume") unless btrfs_volume?("#{snap_pathdir}") == true
      execute "create snapshot #{snap_pathdir}/#{snap_name}" do
        command "btrfs subvolume snapshot #{snap_mode} #{pathdir}/#{name} #{snap_pathdir}/#{snap_name}"
        not_if { !::File.exists?("#{pathdir}/#{name}") or ::File.exists?("#{snap_pathdir}/#{snap_name}")}
        timeout 10
      end
    end
  end
end

action :delete_snapshot do
  unless @new_resource.exists
    snap_pathdir = new_resource.snap_pathdir
    snap_name = new_resource.snap_name
    converge_by "deleting snapshot  #{snap_name}" do
      Chef::Application.fatal!("Provider BTRFS - #{snap_pathdir} is not a BTRFS volume") unless btrfs_volume?("#{snap_pathdir}") == true
      execute "delete_snapshot #{snap_pathdir}/#{snap_name}" do
        command "btrfs subvolume delete #{snap_pathdir}/#{snap_name}"
        only_if  "btrfs subvolume list -s #{snap_pathdir} | grep #{snap_name}"
        timeout 10
      end
    end
  end
end

action :mount_device do
  unless @new_resource.exists
    device_source = new_resource.device_source
    subvol_name = new_resource.subvol_name
    device_dest = new_resource.device_dest
    if ( new_resource.mount_opt )
      mount_opt = new_resource.mount_opt #must begin by comma
    else 
      mount_opt = ""
    end
    converge_by "mounting #{device_source} on #{device_dest}" do
      Chef::Application.fatal!("Provider BTRFS - #{device_source} is not a BTRFS volume") unless btrfs_disk?("#{device_source}") == true
      bash "mounting #{device_source} on #{device_dest}" do
        code <<-EOH
        if [ ! -d "#{device_dest}" ]; then
        mkdir -p #{device_dest}
        fi
        mount -t btrfs -o subvol=#{subvol_name}#{mount_opt} #{device_source} #{device_dest}
        if [ $? -ne 0 ]; then
        echo "BTRFS mount_device failed"
        exit 1
        fi
        exit 0
        EOH
        not_if  "btrfs subvolume show #{device_dest} | grep #{subvol_name}"
      end
    end
  end
end

action :umount_device do
  unless @new_resource.exists
    subvol_name = new_resource.subvol_name
    device_dest = new_resource.device_dest
    converge_by "umounting on #{device_dest}" do
      Chef::Application.fatal!("Provider BTRFS - #{device_dest} is not a BTRFS volume") unless btrfs_volume?("#{device_dest}") == true
      bash "umounting #{device_dest}" do
        code <<-EOH
        if [ ! -d "#{device_dest}" ]; then
        echo "Device not exist"
        exit 0 
        fi
        umount #{device_dest}
        if [ $? -ne 0 ]
        echo "umount_device failed"
        exit 1
        fi
        exit 0
        EOH
      end
    end
  end
end

def btrfs_volume?(path)
  unless ::File.directory? path
    return false
  end
  return true if ::File.stat(path).ino == 256
  false
end

def btrfs_disk?(path)
  return true if (%x(file -sL #{path}|grep BTRFS).include?("BTRFS"))
  false
end
