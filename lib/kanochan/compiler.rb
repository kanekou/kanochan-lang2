# conding: utf-8
require 'strscan'

module Kanochan
  class Compiler
    class ProgramError < StandardError; end
    
    NUM = /([ふえ]+)ぇ/
    LABEL = NUM
    
    def self.compile(src)
      new(src).compile
    end
    
    def initialize(src)
      @src = src
      @str = nil
    end
    
    def compile
      @str = StringScanner.new(bleach(@src))
      instructions = []
      instructions.push(step) until @str.eos?
      instructions
    end
    
    
    private
    
    def bleach(src) #空白以外の文字を消去する
      src.gsub(/[^ふえぇ]/, "")
    end
    
    def step #構文解析
      case
      when @str.scan(/ふふ#{NUM}/)        then [:push, num(@str[1])]
      when @str.scan(/ふぇふ/)            then [:dup]
      when @str.scan(/ふえふ#{NUM}/)      then [:copy, num(@str[1])]
      when @str.scan(/ふぇえ/)            then [:swap]
      when @str.scan(/ふぇぇ/)            then [:discard]
      when @str.scan(/ふえぇ#{NUM}/)      then [:slide, num(@str[1])]
      
      when @str.scan(/えふふふ/)          then [:add]
      when @str.scan(/えふふえ/)          then [:sub]
      when @str.scan(/えふふぇ/)          then [:mul]
      when @str.scan(/えふえふ/)          then [:div]
      when @str.scan(/えふええ/)          then [:mod]
      
      when @str.scan(/ええふ/)            then [:heap_write]
      when @str.scan(/えええ/)            then [:heap_read]
      
      when @str.scan(/ぇふふ#{LABEL}/)    then [:label, label(@str[1])]
      when @str.scan(/ぇふえ#{LABEL}/)    then [:call, label(@str[1])] 
      
      when @str.scan(/ぇふぇ#{LABEL}/)    then [:jump, label(@str[1])]
      when @str.scan(/ぇえふ#{LABEL}/)    then [:jump_zero, label(@str[1])]
      when @str.scan(/ぇええ#{LABEL}/)    then [:jump_negative, label(@str[1])]
      when @str.scan(/ぇえぇ/)            then [:return]
      when @str.scan(/ぇぇぇ/)            then [:exit]
      
      when @str.scan(/えぇふふ/)          then [:char_out]
      when @str.scan(/えぇふえ/)          then [:num_out]
      when @str.scan(/えぇえふ/)          then [:char_in]
      when @str.scan(/えぇええ/)          then [:num_in]
      else
        raise ProgramError, "どの命令にもマッチしませんでした"
      end
    end
    
    def num(str) #kanochan文字を2進数に変換する
      # 変な入力を受け取った場合
      raise ArgumentError, "数値はスペースとタブで指定ください(#str.inspect})" if str !~ /\A[ふえ]+\z/
      str.sub(/\Aふ/, "+").sub(/\Aえ/, "-").gsub(/ふ/, "0").gsub(/え/, "1").to_i(2)
    end
    
    def label(str)
      str
    end
  end
end

# if $0 == __FILE__
#   p Kanochan::Compiler.compile("ふふふえぇえぇふえぇぇぇ")
# end
