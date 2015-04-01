def application_url(hash)
  "#{hash['proxy_ssl'] && hash['proxy_ssl']['enabled'] ? 'https':'http'}://#{Array(hash['server_name']).first}"
end

