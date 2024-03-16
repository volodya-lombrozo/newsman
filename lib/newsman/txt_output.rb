class Txtout
  def initialize(root=".")
    @root=root
  end
  def print(report)
    puts "Create a file in a directory #{@root}"
    file = File.new(File.join(@root, "output.txt"), "w")
    puts "File #{file.path} was successfully created"
    file.puts report
    puts "Report was successfully printed to a #{file.path}"
    file.close
  end
end
