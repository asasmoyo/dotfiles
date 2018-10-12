require 'erb'
require 'ostruct'

def render_tpl(source, dest, vars={})
  File.write(
    dest,
    ERB.new(File.read(source)).result(OpenStruct.new(vars).instance_eval { binding }),
  )
end
