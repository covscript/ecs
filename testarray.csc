var a  = new array
a.push_back(1)
a.push_back(2)
a.push_back(3)
a.push_back(4)
a.push_back(5)
a.push_back(6)

for iter = a.begin, iter != a.end, iter.next() 

    if iter.data == 4
        iter = a.erase(iter)
    end

end

foreach n in a do system.out.print(to_string(n) + " , ")