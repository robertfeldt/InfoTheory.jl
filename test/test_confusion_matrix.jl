x = [0, 0, 1, 1, 1]
y = [0, 1, 0, 1, 1]
cm = IntConfusionMatrix(x, y)

@test typeof(cm) <: InfoTheory.ConfusionMatrix

@test sort(InfoTheory.xvalues(cm)) == [0, 1]
@test sort(InfoTheory.yvalues(cm)) == [0, 1]

xi0 = InfoTheory.xindex(cm, 0)
xi1 = InfoTheory.xindex(cm, 1)
@test in(xi0, 1:2)
@test in(xi1, 1:2)
@test xi0 != xi1

yi0 = InfoTheory.yindex(cm, 0)
yi1 = InfoTheory.yindex(cm, 1)
@test in(yi0, 1:2)
@test in(yi1, 1:2)
@test yi0 != yi1

@test count(cm, 0, 0) == 1
@test count(cm, 0, 1) == 1
@test count(cm, 1, 0) == 1
@test count(cm, 1, 1) == 2


x2 = [0, 0, 1, 1, -1]
y2 = [0, 1, 0, 1, 1]
cm2 = IntConfusionMatrix(x2, y2)
@test sort(InfoTheory.xvalues(cm2)) == [-1, 0, 1]
@test sort(InfoTheory.yvalues(cm2)) == [0, 1]

@test count(cm2, 0, 0) == 1
@test count(cm2, 0, 1) == 1
@test count(cm2, 1, 0) == 1
@test count(cm2, 1, 1) == 1
@test count(cm2, -1, 1) == 1
@test count(cm2, -1, 0) == 0