arnestr = "arne" ^ 1000
shortarnestr = "arne" ^ 100
bsofstr = "bsof" ^ 1000

@test ncd(shortarnestr, arnestr) < ncd(shortarnestr, bsofstr)