require 'erb'
require 'ostruct'

def render_tpl(source, dest, vars={})
  puts "installing #{source} to #{dest}"
  File.write(
    dest,
    ERB.new(File.read(source)).result(OpenStruct.new(vars).instance_eval { binding }),
  )
end
