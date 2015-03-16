ssh_private_key = encrypted_data_bag_item_for_environment(node['mo_application']['backup']['ssh_key']['databag'],
                                                          node['mo_application']['backup']['ssh_key']['id']) rescue nil


extend MoApplication::SetupSSH

setup_ssh(node['mo_application']['backup']['user'], node['mo_application']['backup']['group'], ssh_private_key['ssh_private_key'], node['mo_application']['backup']['ssh_key']['id']) if ssh_private_key
