cespi_application_chroot '/tmp/chroot_with_copy_files' do
  copy_files %w(/dev/null /bin/bash)
end
