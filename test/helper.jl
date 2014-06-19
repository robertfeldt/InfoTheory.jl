using InfoTheory

NumTestRepetitions = 10

approxeq(x, y, delta = 1e-3) = abs(x-y) < delta