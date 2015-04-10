# Return default_url if present or first url behind reverse_proxy or http://default_server_name
def application_url(hash)
  return hash['default_url'] if hash['default_url']
  default_server_name = Array(hash['server_name']).first
  server_names = hash['reverse_proxy'] && hash['reverse_proxy'].map do |name, options| 
    "#{options && options['ssl'] ? 'https' : 'http'}://#{options && options['server_name'] || default_server_name}"
  end || []
  return server_names.first unless server_names.empty?
  "http://#{default_server_name}"
end

