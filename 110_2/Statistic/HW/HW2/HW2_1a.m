num = "Total quantity of products: ";

n = input(num);
rate = "Defective rate(%): ";
r = input(rate);

answer = defect(n, r);
disp(answer);

function [answer] = defect(n, r)
    sample = zeros(1, n);
    d = 0;
    for i = 1:n
        x = randperm(n, 1);
        if(x <= r * 0.01 * n)
            d = d + 1;
            sample(i) = 1;
            disp(i)
        end
    end
    p = n - d;
    answer = [p, d];
end

