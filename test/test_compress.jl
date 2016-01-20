c = InfoTheory.LibzCompressor()

str1 = "a" ^ 100
cstr1 = compress(c, str1)
@test typeof(cstr1) <: AbstractString
@test length(cstr1) < 100

str2 = "b" ^ 100
@test clen(c, str1) < clen(c, str1 * str2)
