n = 1;
a = IH(1);
draw(n, a, 1);

n = 2;
b = IH(2);
draw(n, b, 2);


n = 20;
c = IH(20);
draw(n, c, 3);


function draw(n, x, i)
    figure(i);
    histfit(x);
    title("Relative Frequency Histogram with n = " + n);
    legend("Irwin-Hall distribution", "Normal distribution");
end



function result = IH(n)
    result = zeros(1,1000000);
    for i=1:n
        for j=1:1000000
            x = rand;
            result(j) = result(j) + x;
        end
    end
end