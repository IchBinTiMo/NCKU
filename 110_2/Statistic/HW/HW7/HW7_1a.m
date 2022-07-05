function result = IH(n)
    result = zeros(1,1000000);
    for i=1:n
        for j=1:1000000
            x = rand;
            result(j) = result(j) + x;
        end
    end
end