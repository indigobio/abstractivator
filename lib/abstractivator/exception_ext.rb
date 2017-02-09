class Exception
  def print_full_trace(io=STDOUT)
    io.puts "#{self.class}: #{message}"
    backtrace.each do |f|
      io.puts "  at #{f}"
    end
    if cause
      io.puts '--- Caused by ---'
      cause.print_full_trace(io)
    end
  end
end
