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
        whiteMatter(i) = 1;
    else
        whiteMatter(i) = 0;
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.25) && (imgArr(i) > 0.16)
        grayMatter(i) = 1;
    else
        grayMatter(i) = 0;
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.16) && (imgArr(i) > 0.09)
        csf(i) = 1;
    else
        csf(i) = 0;
    end
end

for i=1:880*640*14
    if (imgArr(i) < 0.09) && (imgArr(i) > 0)
        bg(i) = 1;
    else
        bg(i) = 0;
    end
end







for i=1:880*640
    if (myImg(i) < 0.35) && (myImg(i) > 0.269)
        myWM(i) = 1;
    else
        myWM(i) = 0;
    end
end

for i=1:880*640
    if (myImg(i) < 0.25) && (myImg(i) > 0.16)
        myGM(i) = 1;
    else
        myGM(i) = 0;
    end
end

for i=1:880*640
    if (myImg(i) < 0.16) && (myImg(i) > 0.09)
        myCSF(i) = 1;
    else
        myCSF(i) = 0;
    end
end


figure;
imshow(myWM, []);
title("White Matter");
figure;
imshow(myGM, []);
title("Gray Matter");
figure;
imshow(myCSF, []);
title("CSF");


