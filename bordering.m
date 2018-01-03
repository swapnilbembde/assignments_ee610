%// Pre-processing
%function out_colour = bordering(BW,img)
BW = (imread('newImage.jpg'));
im = (imread('1.jpg'));

%imshow(im);
out = imclearborder(BW); %// Remove pixels along border

%// Obtain pixels that are along border
out2 = BW; %// Make copy
%out2(out) = 0; %// Set pixels not belonging to boundary to 0

%// Fill holes for both regions separately
out_fill = imfill(out, 'holes');
out2_fill = ~bwareaopen(~out2, 500);

%// Merge together
final_out = out_fill | out2_fill; 

%// Show final output
figure;
%imshow(final_out);

%// Bonus - Show perimeter of output in green
perim = bwperim(final_out);
%imshow(perim);
red = final_out;
green = final_out;
blue = final_out;
red(perim) = 0;
blue(perim) = 0;
out_colour1 = 255*uint8(cat(3, red, green, blue));
imshow(out_colour1);

out_colour = im.*out_colour1;
figure;
imshow(out_colour);
