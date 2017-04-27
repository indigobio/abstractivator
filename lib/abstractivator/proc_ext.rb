require 'abstractivator/enumerable_ext'
require 'abstractivator/array_ext'

module MethodAndProcExtensions
  # returns a version of the procedure that accepts any number of arguments
  def loosen_args
    proc do |*args, **kws, &block|
      Proc.loose_call(self, args, kws, &block)
    end
  end

  KEYWORD_PARAMETER_TYPES = %i(key keyreq keyrest).freeze

  def accepts_keywords
    @accepts_keywords ||= parameters.any?{|param| KEYWORD_PARAMETER_TYPES.include?(param.first)}
  end
end

class Proc
  include MethodAndProcExtensions

  # composes this procedure with another procedure
  # f.compose(g) ==> proc { |x| f.call(g.call(x)) }
  def compose(other)
    proc{|x| self.call(other.call(x))}
  end

  # composes procedures.
  # compose(f, g, h) returns the procedure
  # proc { |x| f.call(g.call(h.call(x))) }
  def self.compose(*procs)
    procs.map(&:to_proc).inject_right(identity) { |inner, p| p.compose(inner) }
  end

  # composes procedures in reverse order.
  # useful for applying a series of transformations.
  # pipe(f, g, h) returns the procedure
  # proc { |x| h.call(g.call(f.call(x))) }
  def self.pipe(*procs)
    Proc.compose(*procs.reverse)
  end

  # makes a pipeline transform as with Proc::pipe
  # and applies it to the given value.
  def self.pipe_value(value, *procs)
    Proc.pipe(*procs).call(value)
  end

  # returns the identity function
  def self.identity
    proc {|x| x}
  end

  # returns a version of the procedure with the argument list reversed
  def reverse_args
    proc do |*args, &block|
      self.call(*args.reverse, &block)
    end
  end

  def proxy_call(*args, **kws, &block)
    if accepts_keywords
      call(*args, **kws, &block)
    elsif kws.any?
      call(*(args + [kws]), &block)
    else
      call(*args, &block)
    end
  end

  LooseCallInfo = Struct.new(:params, :accepts_arg_splat, :total_arity, :req_arity,
                             :requires_kw_customization, :all_key_names, :kw_padding)

  # Tries to coerce x into a procedure, then calls it with the given argument list.
  # If x cannot be coerced into a procedure, returns x.
  # This method is optimized for use cases typically found in tight loops,
  # namely where x is either a symbol or a keyword-less fixed-arity proc.
  # It attempts to minimize the number of intermediate arrays created for these cases
  # (as would be produced by calls to #map, #select, #take, #pad_right, etc.)
  # CPU overhead created by loose_call is bad, but unexpected memory consumption would
  # be worse, considering Proc#call has zero memory footprint.
  # These optimizations produce a ~5x speedup, which is still 2-4x slower than
  # regular Proc#call.
  def self.loose_call(x, args, kws={}, &block)
    return x.to_proc.call(*args) if x.is_a?(Symbol) # optimization for a typical use case
    x = x.to_proc if x.respond_to?(:to_proc)
    return x unless x.callable?

    # cache proc info for performance
    info = x.instance_variable_get(:@loose_call_info)
    unless info
      params = x.parameters
      info = LooseCallInfo.new
      info.params = params
      info.req_arity = params.count { |p| p.first == :req }
      info.total_arity = info.req_arity + params.count { |p| p.first == :opt }
      info.accepts_arg_splat = params.any? { |p| p.first == :rest }
      accepts_kw_splat = params.any? { |p| p.first == :keyrest }
      has_kw_args = params.any? { |(type, name)| (type == :key || type == :keyreq) && !name.nil? }
      info.requires_kw_customization = (has_kw_args || kws.any?) && !accepts_kw_splat
      if info.requires_kw_customization
        opt_key_names = info.params.select { |(type, name)| type == :key && !name.nil? }.map(&:value)
        req_key_names = info.params.select { |(type, name)| type == :keyreq && !name.nil? }.map(&:value)
        info.all_key_names = opt_key_names + req_key_names
        info.kw_padding = req_key_names.hash_map { nil }
      end
      x.instance_variable_set(:@loose_call_info, info)
    end

    # customize args
    unless info.accepts_arg_splat
      args = args.take(info.total_arity) if args.size > info.total_arity
      args = args.pad_right(info.req_arity) if args.size < info.req_arity
    end

    # customize keywords
    if info.requires_kw_customization
      kws = info.kw_padding.merge(kws.select { |k| info.all_key_names.include?(k) })
    end

    if kws.any?
      x.call(*args, **kws, &block)
    else
      x.call(*args, &block)
    end
  end

  def self.loosen_varargs!(args)
    if args.size == 1 && args.first.is_a?(Array)
      real_args = args.first
      args.clear
      args.concat(real_args)
      nil
    end
  end
end

class Method
  include MethodAndProcExtensions
end

class UnboundMethod
  # returns a version of the procedure that takes the receiver
  # (that would otherwise need to be bound with .bind()) as
  # the first argument
  def explicit_receiver
    proc do |receiver, *args, &block|
      self.bind(receiver).call(*args, &block)
    end
  end
end

class Array
  # A syntactic hack to get hash values.
  # xs.map(&:name)      works when xs is an array of objects, each with a #name method. (built into ruby)
  # xs.map(&[:name])    works when xs is an array of hashes, each with a :name key.
  # xs.map(&['name'])   works when xs is an array of hashes, each with a 'name' key.
  def to_proc
    raise 'size must be exactly one' unless size == 1
    proc{|x| x[first]}
  end
end

class Object
  def callable?
    respond_to?(:call)
  end

  def proxy_send(method_name, *args, **kws, &block)
    if method(method_name).accepts_keywords
      send(method_name, *args, **kws, &block)
    elsif kws.any?
      send(method_name, *(args + [kws]), &block)
    else
      send(method_name, *args, &block)
    end
  end
end
