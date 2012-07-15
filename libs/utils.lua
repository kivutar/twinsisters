function sign(x)
  return x < 0 and -1 or (x > 0 and 1 or 0)
end

function count(dict)
  for _,_ in pairs(dict) do
    return true
  end
  return false
end