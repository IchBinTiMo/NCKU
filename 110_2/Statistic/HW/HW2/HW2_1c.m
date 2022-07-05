result = zeros(10,4);
answer = zeros(10, 2);

for i = 1:3
    switch(i)
        case 1
            n = 30000;
            r = 2;
        case 2
            n = 45000;
            r = 3;
        case 3
            n = 25000;
            r = 2;
    end
    for j = 1:10
        output = defect(n, r);
        result(j, i) = output(2);
    end
end

for i = 1:10
    result(i ,4) = result(i, 1) + result(i, 2) + result(i, 3);
    answer(i, 1) = result(i, 3) / result(i, 4);
    answer(i, 2) = (answer(i, 1) - 10/49) / (10/49) * 100;
end

disp(answer);



save()

toSave = answer(:, 2);

save("HW2_1c.mat", "toSave");

% disp(result);

%plot = histogram(result(:, 2));

%title("Relative Frequency Histogram");
%xlabel("Quantity of Defective Product");
%ylabel("Count");

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

