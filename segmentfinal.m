
prompt1 = 'Please enter the image number\n';
image_no = input(prompt1)
im = (imread(strcat(num2str(image_no),'.jpg')));
%figure(1);
%imshow(im);

prompt2 = 'Please enter the possible number of segments visible in the image\n';
k = input(prompt2)
startTime = tic;

features = zeros(size(im,1), size(im,2),5);
im = double(im);
imVar = stdfilt(im);
imVar = imVar/max(max(max(imVar)));
for i=1:3
    features(:,:,i) = imfilter(im(:,:,i),imgaussfilt(im(:,:,i)));
    features(:,:,i) = (features(:,:,i)-min(min(features(:,:,i))))/(max(max(features(:,:,i)))-min(min(features(:,:,i))));
end

vec = 1:size(im,2);
features(:,:,4) = repmat(vec,size(im,1),1);
features(:,:,4) = (features(:,:,4)-min(min(features(:,:,4))))/(max(max(features(:,:,4)))-min(min(features(:,:,4))));
vec = 1:size(im,1);
features(:,:,5) = repmat(vec',1,size(im,2));
features(:,:,5) = (features(:,:,5)-min(min(features(:,:,5))))/(max(max(features(:,:,5)))-min(min(features(:,:,5))));

minR = min(min(im(:,:,1)));
minB = min(min(im(:,:,3)));
minG = min(min(im(:,:,2)));
maxR = max(max(im(:,:,1)));
maxG = max(max(im(:,:,2)));
maxB = max(max(im(:,:,3)));

psize=2;
DCTFeatures = zeros(size(im,1),size(im,2),10*3+100+6);
im2 = zeros(size(im,1)+4, size(im,2)+4, 3);
im2(psize+1:psize+1+size(im,1)-1, psize+1:psize+1+size(im,2)-1, :) = im;
for i=1:size(im,1)
    for j=1:size(im,2)
        tempDCT1 = dct2(im2(i:i+4 , j:j+4,1));
        tempDCT1 = tempDCT1(:);
        tempDCT1(1:10) = (tempDCT1(1:10)-min(tempDCT1(1:10)))/(max(tempDCT1(1:10))-min(tempDCT1(1:10)));
        colorpatch1 = im2(i:i+4 , j:j+4,1);
        colorpatch1 = (colorpatch1 - minR)/(maxR-minR);
        tempDCT2 = dct2(im2(i:i+4 , j:j+4,2));
        tempDCT2 = tempDCT2(:);
        tempDCT2(1:10) = (tempDCT2(1:10)-min(tempDCT2(1:10)))/(max(tempDCT2(1:10))-min(tempDCT2(1:10)));
        colorpatch2 = im2(i:i+4 , j:j+4,2);
        colorpatch2 = (colorpatch2 - minG)/(maxG-minG);
        tempDCT3 = dct2(im2(i:i+4 , j:j+4,3));
        tempDCT3 = tempDCT3(:);
        tempDCT3(1:10) = (tempDCT3(1:10)-min(tempDCT3(1:10)))/(max(tempDCT3(1:10))-min(tempDCT3(1:10)));
        var1 = var(tempDCT1(1:10));
        var2 = var(tempDCT2(1:10));
        var3 = var(tempDCT3(1:10));
        colorpatch3 = im2(i:i+4 , j:j+4,3);
        colorpatch3 = (colorpatch3 - minB)/(maxB-minB);
        tempFFT1 = abs(fft2(rgb2gray(im2(i:i+4 , j:j+4,:))));
        tempFFT1 = tempFFT1(:);
        tempFFT1(:) = (tempFFT1(:)-min(tempFFT1(:)))/(max(tempFFT1(:))-min(tempFFT1(:)));
        DCTFeatures(i,j,:) = cat(1,tempDCT1(1:10),tempDCT2(1:10),tempDCT3(1:10),tempFFT1(:),colorpatch1(:),colorpatch2(:),colorpatch3(:),var1,var2,var3,imVar(i,j,3),imVar(i,j,2),imVar(i,j,1));
    end
end
%weighting 
im_sobelR = GSobel(im(:,:,1),3);
im_sobelG = GSobel(im(:,:,2),3);
im_sobelB = GSobel(im(:,:,3),3);

for i=1:size(im,1)
    for j=1:size(im,2)
        if im_sobelG(i,j)/max(max(im_sobelG))>0.5
            DCTFeatures(i,j,81:105) = 0.01*DCTFeatures(i,j,81:105);
        end
        if im_sobelR(i,j)/max(max(im_sobelR))>0.5
            DCTFeatures(i,j,56:80) = 0.01*DCTFeatures(i,j,56:80);
        end
        if im_sobelB(i,j)/max(max(im_sobelB))>0.3
            DCTFeatures(i,j,106:130) = 0.01*DCTFeatures(i,j,106:130);
        end
        if imVar(i,j,:) <0.1
            DCTFeatures(i,j,31:55) = 0.01 * DCTFeatures(i,j,31:55);
        end        
    end
end


features = cat(3,features,DCTFeatures);
reshapedFeatures = reshape(features, [size(features,1)*size(features,2) size(features,3)]);

%%clustering 
ids = kmeans(reshapedFeatures,k);
reshapedIdx = reshape(ids, [size(im,1) size(im,2)]);

figure(2);
im_segmented = im(:,:,:);

 for i = 1:size(im,1)
     for j = 1:size(im,2)
         im_segmented(i,j,:) = [(reshapedIdx(i,j)-1)*255.0/(k),(reshapedIdx(i,j)-1)*255.0/(k),(reshapedIdx(i,j)-1)*255.0/(k)];
     end
 end

%for i=1:k
%    imshow(reshapedIdx == i);
%    waitforbuttonpress;
%end
imshow(uint8(im_segmented)); 
elapsedTime = toc(startTime);
message = sprintf('Done!\n\nElapsed time = %.2f seconds.', elapsedTime);
disp(message);