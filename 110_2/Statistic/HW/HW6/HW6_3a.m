images = load('MRI_brain_14slices.mat');

for i = 1:14
    imgArr = mat2gray(images.MRI_brain(:, :, i));
    figure(i);
    imshow(imgArr, []);
end