resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_scripts {
    'cl_weather.lua',
}

server_scripts {
    'sv_weather.lua',
}

server_exports {'GetWeather'}
exports {}