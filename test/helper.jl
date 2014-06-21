using InfoTheory

NumTestRepetitions = 30

function approxeq(x, y, delta = 1e-3)
  absdelta = abs(x-y) 
  if absdelta >= delta
    error("Expected $x to be within $delta of $y (but diff is $absdelta)")
    false
  else
    true
  end
end