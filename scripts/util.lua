function Comp_alphabetically(a, b)
   a = a.text
   b = b.text
   return a < b
end

function Comp_tag_number(a, b)
   a = a.tag_number
   b = b.tag_number
   return a > b
end
