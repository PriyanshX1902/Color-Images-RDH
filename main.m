function main
rng(0)

message_lengths = [20000 50000 80000];
results = zeros(75, 3);
for j1 = 2:2
    
    psnr_sum = 0;
    for i1=1:1
        if i1<10
            original_image=double(imread(strcat(strcat('./Original/kodim0', num2str(i1)), '.png')));
        else
            original_image=double(imread(strcat(strcat('./Original/kodim', num2str(i1)), '.png')));
        end
        message_length= message_lengths(j1);
        original_message=randi([0,1],1,message_length);

        [watermarked_image em_message max_result] = main_encode(original_image, original_message);
        psnr_value = psnr(original_image, watermarked_image,255);
        psnr_sum = psnr_sum + max_result;
        results((j1-1)*25+i1, 1) = i1;
        results((j1-1)*25+i1, 2) = message_length;
        results((j1-1)*25+i1, 3) = max_result;
        if isempty(watermarked_image)
            disp('failed to embed')
        else
            disp(['Best psnr for the payload is ' num2str(psnr_value)])
        end

        %Decoding check
        [re_original, re_message]=main_decode(watermarked_image, em_message);
        final_message = re_message;

        %check if extracted messages are correct and pixels are recovered
        if isequal(re_original,original_image)
            %disp('Recovered the original image')
        else
            %disp('Failed to recover the original image')
        end

        if isequal(final_message,original_message)

            disp('Recovered the payload data in all channels')
        else
            disp('Failed to recover the payload')
        end
    end
    
    results(j1*25, 2) = psnr_sum/24;
end
%csvwrite('kodakresults2.csv', results);
