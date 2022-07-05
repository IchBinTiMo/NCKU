param = [25 30 1250 300 0; 
         75 30 1750 300 0];
param(:, : ,2) = [20 20 1250 200 0; 
                  75 30 1750 300 0];
title = ["Distribution 1 in Case 1"; 
         "Distribution 2 in Case 1";
         "Distribution 1 in Case 2";
         "Distribution 2 in Case 2"];

%disp(param);

for page = 1:2
    p = zeros(1001, 101);
    p(:, :, 2) = zeros(1001, 101);
    
    for row = 1:2
        p(:, :, row) = bnm(param(row, :, page), title(row + page, :), row * page + row);
    end

    pdiff = p(:, :, 1) - p(:, :, 2);

    [X, Y] = meshgrid(0:1:100, 1000:1:2000);

    C = contours(X, Y, pdiff, [0, 0]);
    Xs = C(1, 2:end);
    Ys = C(2, 2:end);
    

    boundary = interp2(X, Y, p(:, :, 2), Xs, Ys);
    figure(10 + page);
    line(Xs, Ys, boundary, 'Color', 'red', 'Linewidth', 3);
    xlim([0 100]);
    ylim([1000 2000]);
    xlabel('Random variable X');
    ylabel('Random variable Y');
end




function pdf = bnm(p, t, i)
    mux = p(1);
    thetax = p(2);
    muy = p(3);
    thetay = p(4);
    ro = p(5);
    [X, Y] = meshgrid(0:1:100, 1000:1:2000);

    z = (((X-mux).^2)/thetax^2)+(((Y-muy).^2)/thetay^2)-(2*ro*((X-mux).*(Y-muy))/(thetax*thetay));
    pdf = exp(-z./ (2 * (1 - ro^2))) / (2 * pi * thetax * thetay * (1 - ro^2) ^ 0.5);
    
    figure(i);
    imagesc([0 100], [1000 2000], pdf);
    xlabel('Random variable X');
    ylabel('Random variable Y');
    title(t);
    %colorbar;
    %colormap('jet');
end


