function main
rng(0)
original_image=double(imread('baboon.png'));
red_channel = double(original_image(:,:, 1));
green_channel = double(original_image(:, :, 2));
blue_channel = double(original_image(:, :, 3));
message_length= 1000;
original_message=randi([0,1],1,message_length);
class(original_message)
watermarked_image_red = main_encode(red_channel, original_message(1:uint32(message_length/3)));
watermarked_image_green = main_encode(green_channel, original_message(uint32(message_length/3)+1:uint32((2*message_length)/3)));
watermarked_image_blue = main_encode(blue_channel, original_message(uint32((2*message_length)/3)+1:end));
watermarked_image = cat(3, watermarked_image_red, watermarked_image_green, watermarked_image_blue);

class(watermarked_image)
figure
imshow(uint8(original_image));
figure
imshow(uint8(watermarked_image));
psnr_value = psnr(original_image, watermarked_image,255);

if isempty(watermarked_image)
    disp('failed to embed')
else
    disp(['Best psnr for the payload is ' num2str(psnr_value)])
end

%Decoding check
[re_original, re_message]=main_decode(watermarked_image(:, :, 1));
final_message = re_message;

%check if extracted messages are correct and pixels are recovered
if isequal(re_original,red_channel)
    disp('Recovered the original image')
else
    disp('Failed to recover the original image')
end


%Decoding check
[re_original, re_message]=main_decode(watermarked_image(:, :, 2));
final_message = [final_message, re_message];

%check if extracted messages are correct and pixels are recovered
if isequal(re_original,green_channel)
    disp('Recovered the original image')
else
    disp('Failed to recover the original image')
end

%Decoding check
[re_original, re_message]=main_decode(watermarked_image(:, : , 3));
final_message = [final_message, re_message];
%check if extracted messages are correct and pixels are recovered
if isequal(re_original,blue_channel)
    disp('Recovered the original image')
else
    disp('Failed to recover the original image')
end


if isequal(final_message,original_message)
    
    disp('Recovered the payload data in all channels')
else
    disp('Failed to recover the payload')
end