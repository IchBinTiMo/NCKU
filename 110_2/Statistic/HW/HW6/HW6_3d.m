clc;

images = load('MRI_brain_14slices.mat');



imgArr = mat2gray(images.MRI_brain);
myImg = mat2gray(images.MRI_brain(:, :, 11));

whiteMatter = imgArr;
grayMatter = imgArr;
csf= imgArr;
bg = imgArr;

myWM = zeros(880, 640);
myGM = zeros(880, 640);
myCSF = zeros(880, 640);

for i=1:880*640*14
    if (imgArr(i) < 0.35) && (imgArr(i) > 0.269)
        whiteMatter(i) = whiteMatter(i);
    else
        whiteMatter(i) = -1;
        
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.25) && (imgArr(i) > 0.16)
        grayMatter(i) = grayMatter(i);
    else
        grayMatter(i) = -1;
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.16) && (imgArr(i) > 0.09)
        csf(i) = csf(i);
    else
        csf(i) = -1;
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.09) && (imgArr(i) > 0)
        bg(i) = 1;
    else
        bg(i) = 0;
    end
end

whiteMatter(whiteMatter == -1) = [];
grayMatter(grayMatter == -1) = [];
csf(csf == -1) = [];

whiteMatter = reshape(whiteMatter, [], 1);
grayMatter = reshape(grayMatter, [], 1);
csf = reshape(csf, [], 1);


normalW = fitdist(whiteMatter, 'Normal');
normalG = fitdist(grayMatter, 'Normal');
normalC = fitdist(csf, 'Normal');



x = 0:1/7884800:1;
yW = normpdf(x, normalW.mu, normalW.sigma);
yG = normpdf(x, normalG.mu, normalG.sigma);
yC = normpdf(x, normalC.mu, normalC.sigma);
ySum = yW + yG + yC;


figure;
plot(x, yW);
hold on;
plot(x, yG, 'Color', 'r');
hold on;
plot(x, yC, 'Color', 'g');

xlabel("Intensity");
ylabel("Probability");
title("Gaussian Distribution(Respective)");
legend("White Matter", "Gray Matter", "CSF");

figure;
plot(x, ySum, 'Color', 'black');

xlabel("Intensity");
ylabel("Probability");
title("Gaussian Distribution(Sum)");
legend("Sum");

