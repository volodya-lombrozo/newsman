class Txtout
  def initialize(root=".")
    @root=root
  end
  def print(report, reporter)
    puts "Create a file in a directory #{@root}"
    file = File.new(File.join(@root, filename(reporter)), "w")
    puts "File #{file.path} was successfully created"
    file.puts report
    puts "Report was successfully printed to a #{file.path}"
    file.close
  end
  def filename(reporter)
    date = Time.new.strftime('%d.%m.%Y')
    "#{date}.#{reporter}.txt"    
  end
end
