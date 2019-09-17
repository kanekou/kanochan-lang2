require 'kanochan/compiler'
require 'kanochan/vm'

module Kanochan
  
  def self.run(src)
    instructions = Kanochan::Compiler.compile(src)
    Kanochan::VM.run(instructions)
  end
  
end
