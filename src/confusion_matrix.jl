# A confusion matrix counts the number of times that the values
# of two (discrete-valued) sequences co-occur.
abstract ConfusionMatrix

type IntConfusionMatrix <: ConfusionMatrix
  xvalues::Vector{Int64}
  yvalues::Vector{Int64}
  counts::Array{Int64, 2}

  function IntConfusionMatrix(x::Vector{Int64}, y::Vector{Int64})
    xvalues = unique(x)
    yvalues = unique(y)
    cm = new(xvalues, yvalues, 
      zeros(Int64, length(xvalues), length(yvalues)))
    count_pairs(cm, x, y)
    return(cm)
  end
end

xvalues(cm::ConfusionMatrix) = cm.xvalues
yvalues(cm::ConfusionMatrix) = cm.yvalues

function xindex(cm::ConfusionMatrix, x)
  index = findfirst(cm.xvalues, x)
  if index == 0
    cm.xvalues = [xvalues, x]
    cm.counts[end+1,:] = zeros(Int64, length(cm.yvalues))
    return length(xm.xvalues)
  else
    return index
  end
end

function yindex(cm::ConfusionMatrix, y)
  index = findfirst(cm.yvalues, y)
  if index == 0
    cm.yvalues = [yvalues, y]
    cm.counts[:,end+1] = zeros(Int64, length(cm.xvalues))
    return length(xm.yvalues)
  else
    return index
  end
end

function count_pairs(cm::ConfusionMatrix, x, y)
  for i in 1:min(length(x), length(y))
    count_pair(cm, x[i], y[i])
  end  
end

count_pair(cm::ConfusionMatrix, x, y) = cm.counts[xindex(cm, x), yindex(cm, y)] += 1
count(cm::ConfusionMatrix, x, y) = cm.counts[xindex(cm, x), yindex(cm, y)]