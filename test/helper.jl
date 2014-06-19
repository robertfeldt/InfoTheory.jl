using InfoTheory

NumTestRepetitions = 30

approxeq(x, y, delta = 1e-3) = abs(x-y) < delta