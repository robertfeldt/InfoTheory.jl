str1 = "arne" ^ 100
str2 = "bsof" ^ 100
str3 = "arnebsof" ^ 100

dm = ncdmatrix([str1, str2, str3])

@test typeof(dm) == Array{Float64,2}

@test dm[1,1] == 0.0
@test dm[2,2] == 0.0
@test dm[3,3] == 0.0

@test dm[1,2] == dm[2,1]
@test dm[1,3] == dm[3,1]
@test dm[2,3] == dm[3,2]

@test dm[1,2] == ncd(str1, str2)
@test dm[1,3] == ncd(str1, str3)
@test dm[2,3] == ncd(str2, str3)