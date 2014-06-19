# Define a minimal testing system that can be used to test GodelTest itself.
using Base.Test

module Minitest

type TestReporter
	start_time::Float64
	num_successes::Integer
	failures
	errors

	function TestReporter()
		new(time(), 0, Any[], Any[])
	end
end

set_start_time(tr::TestReporter) = tr.start_time = time()

num_failures(tr::TestReporter) = length(tr.failures)
num_errors(tr::TestReporter) = length(tr.errors)
num_assertions(tr::TestReporter) = tr.num_successes + num_failures(tr) + num_errors(tr)

pluralize(str::String, num) = (num == 1) ? str : (str * "s")

function report(tr::TestReporter)
	elapsed = time() - tr.start_time

	for i in 1:length(tr.failures)
		println(i, ") Failure:\n", tr.failures[i].expr)
	end

	for i in 1:length(tr.errors)
		println(i, ") Error:\n", tr.errors[i].expr)
		rethrow(tr.errors[i])
	end

	numassertions = num_assertions(tr)
	assertions_per_sec = numassertions/elapsed
	println("\n\n", 
		@sprintf("Finished in %.2f seconds (%.1f assertions/sec)", elapsed, assertions_per_sec)
	)

	assertions_string = numassertions == 1 ? "assertion" : "assertions"

	numfailures = num_failures(tr)
	numerrors = num_errors(tr)

	println("\n", 
		numassertions, pluralize(" assertion", numassertions), ", ",
		numfailures, pluralize(" failure", numfailures), ", ",
		numerrors, pluralize(" error", numerrors)
	)

	if (numfailures + numerrors) > 0
		exit(-1)
	else
		exit(0)
	end
end

TR__ = TestReporter()

CountsPerLine = 50
global Minitest_counts = 0

function log_result(indicator)
	global Minitest_counts
	print(indicator)
	Minitest_counts += 1
	if mod(Minitest_counts, CountsPerLine) == 0
		print(" $(Minitest_counts)\n")
	end
	flush(STDOUT)
end

# Include the file but also print to stdout and indent with spaces so that
# the log looks nice.
function include(filename)
	println("\n\nLoading $(filename):")
	global Minitest_counts
	spaces = map((x) -> " ", 1:mod(Minitest_counts, CountsPerLine))
	print(join(spaces))
	Main.include(filename)
end

function minitest_handler(r::Test.Success)
	TR__.num_successes += 1
	log_result(".")
end

function minitest_handler(r::Test.Failure)
	push!(TR__.failures, r)
	log_result("F")
end

function minitest_handler(r::Test.Error)
	push!(TR__.errors, r)
	log_result("E")
	#rethrow(r)
end

function do_tests(block)
	set_start_time(TR__)
	Base.Test.with_handler(block, minitest_handler)
	report(TR__)
end

end

macro repeatedly(expr)
	num_reps = isdefined(:NumTestRepetitions) ? NumTestRepetitions : 10
	quote
		for i in 1:$(num_reps)
			$(expr)
		end
	end
end