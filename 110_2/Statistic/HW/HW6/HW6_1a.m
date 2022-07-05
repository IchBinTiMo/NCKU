param = [50 20 1500 200 0; 
         50 20 1500 200 0.3; 
         50 20 1500 200 0.8;
         50 20 1500 200 -0.8];
title = ["[\mu_x, \sigma_x, \mu_x, \sigma_y, \rho] = [50, 20, 1500, 200, 0]";
         "[\mu_x, \sigma_x, \mu_x, \sigma_y, \rho] = [50, 20, 1500, 200, 0.3]";
         "[\mu_x, \sigma_x, \mu_x, \sigma_y, \rho] = [50, 20, 1500, 200, 0.8]";
         "[\mu_x, \sigma_x, \mu_x, \sigma_y, \rho] = [50, 20, 1500, 200, -0.8]"];



for i = 1:4
    bnm(param(i,:), title, i);
end


function bnm(p, t, i)
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
    title(t(i));
    colorbar;
    colormap('jet');
end


