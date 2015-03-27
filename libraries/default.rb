def application_url(hash)
  "#{hash['proxy_ssl'] && hash['proxy_ssl']['enabled'] ? 'https':'http'}://#{hash['server_name']}"
end

