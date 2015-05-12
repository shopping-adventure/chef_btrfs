actions :create_subvolume, :delete_subvolume, :create_snapshot, :delete_snapshot, :mount_device, :umount_device

attribute :pathdir, :kind_of => String
attribute :name, :kind_of => String
attribute :snap_path, :kind_of => String
attribute :snap_name, :kind_of => String
attribute :snap_mod, :kind_of => String
attribute :device_source, :kind_of => String
attribute :device_dest, :kind_of => String
attribute :mount_opt, :kind_of => String
attribute :subvol_name, :kind_of => String

attr_accessor :exists

def initialize(*args)
  super
  @action = :nothing
end
