clc;
images = load('MRI_brain_14slices.mat');


imgArr = mat2gray(images.MRI_brain);
figure;
imhist(imgArr, 250);
title("Intensity Histogram");
disp(size(h));
xlabel("Intensity");
ylabel("Count");
