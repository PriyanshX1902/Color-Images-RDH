function [re_original, re_message]=main_decode(watermarked_image, em_message)

[re_mod_P2_green, re_message2]=decode_skewed_histogram_shifting(watermarked_image(:, :, 2),1, watermarked_image(:, :, 1), 3);
[re_mod_P1_green, re_message1]=decode_skewed_histogram_shifting(re_mod_P2_green,0,watermarked_image(:, :, 1) , 3);
[re_mod_P2_blue, re_message4]=decode_skewed_histogram_shifting(watermarked_image(:, :, 3),1, re_mod_P1_green, 2);
[re_mod_P1_blue, re_message3]=decode_skewed_histogram_shifting(re_mod_P2_blue,0, re_mod_P1_green, 2);
[re_mod_P2_red, re_message6]=decode_skewed_histogram_shifting(watermarked_image(:, :, 1),1, re_mod_P1_green, 1);
[re_mod_P1_red, re_message5]=decode_skewed_histogram_shifting(re_mod_P2_red,0, re_mod_P1_green, 1);
re_message=[re_message5 re_message6 re_message3 re_message4 re_message1 re_message2];
re_message_green = [re_message1 re_message2];
re_message_blue = [re_message3 re_message4];
re_message_red = [re_message5 re_message6];
len = floor(length(em_message)/3);


%Undo preprocessing
[re_n re_m]=size(watermarked_image(:,:,1));
re_message_length_max=floor(log2(re_n*re_m));
re_length_loc_map_max=ceil(log2((re_n-2)*(re_m-2)));

%side information
re_border_pixel_red=re_message(1:re_message_length_max+6);
start_pos=re_message_length_max+6+1;
re_location_map_length_red=bi2de(re_message(start_pos:start_pos+re_length_loc_map_max-1));
start_pos=start_pos+re_length_loc_map_max;
re_location_map_red=re_message(start_pos:start_pos+re_location_map_length_red-1);
re_message(1:start_pos+re_location_map_length_red-1)=[];

re_border_pixel_green=re_message(1:re_message_length_max+6);
start_pos=re_message_length_max+6+1;
re_location_map_length_green=bi2de(re_message(start_pos:start_pos+re_length_loc_map_max-1));
start_pos=start_pos+re_length_loc_map_max;
re_location_map_green=re_message(start_pos:start_pos+re_location_map_length_green-1);
re_message(1:start_pos+re_location_map_length_green-1)=[];

re_border_pixel_blue=re_message(1:re_message_length_max+6);
start_pos=re_message_length_max+6+1;
re_location_map_length_blue=bi2de(re_message(start_pos:start_pos+re_length_loc_map_max-1));
start_pos=start_pos+re_length_loc_map_max;
re_location_map_blue=re_message(start_pos:start_pos+re_location_map_length_blue-1);
re_message(1:start_pos+re_location_map_length_blue-1)=[];
%Recover border pixel
re_mod_P1_red(1:re_message_length_max+6)=bitxor(bitxor(re_mod_P1_red(1:re_message_length_max+6),mod(re_mod_P1_red(1:re_message_length_max+6),2)),re_border_pixel_red);
re_mod_P1_green(1:re_message_length_max+6)=bitxor(bitxor(re_mod_P1_green(1:re_message_length_max+6),mod(re_mod_P1_green(1:re_message_length_max+6),2)),re_border_pixel_green);
re_mod_P1_blue(1:re_message_length_max+6)=bitxor(bitxor(re_mod_P1_blue(1:re_message_length_max+6),mod(re_mod_P1_blue(1:re_message_length_max+6),2)),re_border_pixel_blue);
if 1
    re_original_red=re_mod_P1_red;
else
    [re_original_red]=re_preproces_image(re_mod_P1_red,re_location_map_red);
end
if 1
    re_original_green=re_mod_P1_green;
else
    [re_original_green]=re_preproces_image(re_mod_P1_green,re_location_map_green);
end
if 1
    re_original_blue=re_mod_P1_blue;
else
    [re_original_blue]=re_preproces_image(re_mod_P1_blue,re_location_map_blue);
end
re_original = cat(3, re_original_red, re_original_green, re_original_blue);
