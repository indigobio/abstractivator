module Kernel
  def lex_module(name, def_block, priv_def_block)
    mod = Module.new do
      priv_mod = Module.new do
        private
        refine(Object, &priv_def_block)
      end
      using priv_mod
      private
      refine(Object, &def_block)
    end
  end
end
