Julia = "julia"
#Julia = "julia03"

Lib = "InfoTheory"

MainCommand = "#{Julia} -L src/#{Lib}.jl"

# The test running files for different subsets
RunTestsFile = 'test/runtests.jl'
TestsFile = FileList["test/**/test*.jl"]

RunSlowTestsFile = 'test/runslowtests.jl'
SlowTestsFiles = FileList["test/**/slowtest*.jl"]

RunAllTestsFile = 'test/runalltests.jl'
AllTestsFiles = TestsFile + SlowTestsFiles

def filter_latest_changed_files(filenames, numLatestChangedToInclude = 1)
  filenames.sort_by{ |f| File.mtime(f) }[-numLatestChangedToInclude, numLatestChangedToInclude]
end

RunLatestTestFile = 'test/runlatestchangedtests.jl'
LatestChangedTestFile = filter_latest_changed_files Dir["test/**/test*.jl"]

require 'pp'

def create_run_test_file(filename, filesToInclude, pathToTests = "", charsToSkip = 5)

	puts "Recreating the file #{filename}, adding files:\n"
	pp(filesToInclude)
	puts "\n"

	File.open(filename, "w") do |fh|
		include_files = filesToInclude.map do |tf| 
			tfr = tf[charsToSkip, (tf.length-charsToSkip)]
			"  Minitest.include(\"#{tfr}\")"
		end.join("\n")
		str = <<EOS
include("#{pathToTests}helper.jl")
include("#{pathToTests}minitest.jl")
Minitest.do_tests() do
#{include_files}
end
EOS
		fh.write str
	end

end

# General dependencies for the test running files
GeneralDependencies = FileList["Rakefile"] + FileList["test/helper.jl"]

file RunTestsFile => (TestsFile + GeneralDependencies) do
	create_run_test_file(RunTestsFile, TestsFile)
end

file RunSlowTestsFile => (SlowTestsFiles + GeneralDependencies) do
	create_run_test_file(RunSlowTestsFile, SlowTestsFiles)
end

file RunAllTestsFile => (AllTestsFiles + GeneralDependencies) do
	create_run_test_file(RunAllTestsFile, AllTestsFiles)
end

file RunLatestTestFile => (LatestChangedTestFile + GeneralDependencies) do
	create_run_test_file(RunLatestTestFile, LatestChangedTestFile)
end


# Declare tasks
desc "Run normal (fast) tests"
task :runtest => RunTestsFile do
  sh "#{MainCommand} #{RunTestsFile}"
end

desc "Run slow tests"
task :runslowtest => RunSlowTestsFile do
  sh "#{MainCommand} #{RunSlowTestsFiles}"
end

desc "Run all tests"
task :runalltest => RunAllTestsFile do
  sh "#{MainCommand} #{RunAllTestsFile}"
end

desc "Run only the latest changed test file"
task :runlatestchangedtest => RunLatestTestFile do
  sh "#{MainCommand} #{RunLatestTestFile}"
end

RunSpikesTestFile = "spikes/runtests.jl"
SpikesTestsFiles = FileList["spikes/**/test*.jl"]
file RunSpikesTestFile => (SpikesTestsFiles + GeneralDependencies) do
  create_run_test_file(RunSpikesTestFile, SpikesTestsFiles, "../test/", 7)
end

Spikes = Dir["spikes/**/*.jl"] - SpikesTestsFiles

desc "Test spikes"
task :tsp => RunSpikesTestFile do
  spikes = Spikes.select {|f| f != RunSpikesTestFile}.join(" -L ")
  sh "#{MainCommand} -L #{spikes} #{RunSpikesTestFile}"
end

# Short hands
task :at => :runalltest
desc "Run normal (fast) tests"
task :rt => :runtest
task :st => :runslowtest
desc "Run only the latest changed test file"
task :t => :runlatestchangedtest

# Default is to run the latest changed test file only:
task :default => :t