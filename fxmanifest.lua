





fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

this_is_a_map "yes"


client_scripts {
  -- '@qpixel-lib/client/cl_rpc.lua',
  '@rhd_library/client/fct.lua',
  'client/cl_*.lua',
}

shared_script {
  'sh_config.lua',
  '@ox_lib/init.lua'
}

server_scripts {
  -- '@qpixel-lib/server/sv_rpc.lua',
  'server/sv_*.lua',
}

ui_page ('ui/index.html')

files {
  'ui/*'
}

