num = "Total quantity of products: ";

n = input(num);
rate = "Defective rate(%): ";
r = input(rate);

result = zeros(1000, 2);
for i = 1:1000
    answer = defect(n, r);
    result(i, 1) = answer(1);
    result(i, 2) = answer(2);
end

toSave = result(:, 2);

save("HW2_1b.mat", "toSave");

disp(result);

plot = histogram(result(:, 2));

title("Relative Frequency Histogram");
xlabel("Quantity of Defective Product");
ylabel("Count");

function [answer] = defect(n, r)
    sample = zeros(1, n);
    d = 0;
    for i = 1:n
        x = randperm(n, 1);
        if(x <= r * 0.01 * n)
            d = d + 1;
            sample(i) = 1;
        end
    end
    p = n - d;
    answer = [p, d];
end

