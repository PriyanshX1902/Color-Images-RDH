function [mod_P, re_message]=decode_skewed_histogram_shifting(P,half, ref_P, channel)
[n m]=size(P);
%border side information extraction
message_length_max=floor(log2(n*m));
b_side_info = P(1:message_length_max+6);
bi_message_length=bi2de(mod(b_side_info(1:end-6),2));
pred_method=bi2de(mod(b_side_info(end-5:end-4),2));
threshold = bi2de(mod(b_side_info(end-3:end),2));
DM = zeros(n, m);
DH = zeros(n, m);
DV = zeros(n, m);
DD = zeros(n, m);
DAD = zeros(n, m);
DE = zeros(n, m);


LC=zeros(n,m);
counter=0;
for i1=2:n-1
    for j1=2:m-1
        if rem(i1+j1,2)==half
            counter=counter+1;
            W=P(i1,j1-1);N=P(i1-1,j1);E=P(i1,j1+1);S=P(i1+1,j1);
            LC(i1,j1)=(abs(N-E)+abs(E-S)+abs(S-W)+abs(W-N)+abs(N-S)+abs(E-W))/6;
            neighbors = zeros(1, 8);
            neighbors(1, 1) = ref_P(i1-1, j1); %N
            neighbors(1, 2) = ref_P(i1, j1-1); %W
            neighbors(1, 3) = ref_P(i1-1, j1-1); %NW
            neighbors(1, 4) = ref_P(i1+1, j1-1); %SW
            neighbors(1, 5) = ref_P(i1-1, j1+1); %NE
            neighbors(1, 6) = ref_P(i1+1, j1); %S
            neighbors(1, 7) = ref_P(i1, j1+1); %E
            neighbors(1, 8) = ref_P(i1+1, j1+1); %SE
            DM(i1, j1) = abs((sum(neighbors)*(1/8))-ref_P(i1, j1));
            DH(i1, j1) = abs(((neighbors(1, 2)+neighbors(1, 7))/2)-ref_P(i1, j1));
            DV(i1, j1) = abs(((neighbors(1, 1)+neighbors(1, 6))/2)-ref_P(i1, j1));
            DD(i1, j1) = intmax;%abs(((neighbors(1, 3)+neighbors(1, 8))/2)-ref_P(i1, j1));
            DAD(i1, j1) = intmax;%abs(((neighbors(1, 4)+neighbors(1, 5))/2)-ref_P(i1, j1));
            DE(i1, j1) = min([DH(i1, j1) DV(i1, j1) DD(i1, j1) DAD(i1, j1)]);
        end
    end
end
pixel_profile=zeros(counter,18);
counter=0;

for i1=2:n-1
    for j1=2:m-1
        if rem(i1+j1,2)==half
            counter=counter+1;
            W=P(i1,j1-1);N=P(i1-1,j1);E=P(i1,j1+1);S=P(i1+1,j1);
            NW=P(i1-1,j1-1);NE=P(i1-1,j1+1);SE=P(i1+1,j1+1);SW=P(i1+1,j1-1);
            w1 = power(abs(N-E)-LC(i1, j1), 2);
            w2 = power(abs(W-S)-LC(i1, j1), 2);
            w3 = power(abs(N-W)-LC(i1, j1), 2);
            w4 = power(abs(S-E)-LC(i1, j1), 2);
            w5 = power(abs(N-S)-LC(i1, j1), 2);
            w6 = power(abs(W-E)-LC(i1, j1), 2);
            W_LC=power(sum([w1 w2 w3 w4 w5 w6])/6, 1/2);%+LC(i1-1,j1-1)+LC(i1-1,j1+1)+LC(i1+1,j1-1)+LC(i1+1,j1+1);
            if DM(i1, j1)-DE(i1, j1)>threshold
                pixel_profile(counter, :) = [W_LC P(i1, j1) ref_P(i1, j1) DH(i1, j1) DV(i1, j1) DD(i1, j1) DAD(i1, j1) N W S E NW NE i1 j1 DM(i1, j1) DE(i1, j1) (j1-1)*n+i1];
            else
                pixel_profile(counter, :)=[W_LC P(i1,j1) N W S E -1 -1 -1 -1 -1 -1 -1 i1 j1 DM(i1, j1) DE(i1, j1) (j1-1)*n+i1];
            end
        end
    end
end
sorted_pixel_profile=sortrows(pixel_profile, 1);

if half == 1
    message_length=bi_message_length-round(bi_message_length/2);
else
    message_length=round(bi_message_length/2);
end

counter=length(sorted_pixel_profile);

location=zeros(1,counter);
mod_P=P;
ec=0;
final_set=0;
temp=zeros(1,counter);

for i1=1:counter
    current_set=sorted_pixel_profile(i1,:);
    loc_y=current_set(18);
    isEdge = current_set(16)-current_set(17);
    if loc_y > message_length_max+6
        %Prediction
        if isEdge>threshold
            if current_set(17)==current_set(4)
                Pred_h = max([current_set(9) current_set(11)]);
                Pred_l = min([current_set(9) current_set(11)]);
            elseif current_set(17)==current_set(5)
                Pred_h = max([current_set(8) current_set(10)]);
                Pred_l = min([current_set(8) current_set(10)]);
            elseif current_set(17)==current_set(6)
                Pred_h = max([current_set(12) current_set(15)]);
                Pred_l = min([current_set(12) current_set(15)]);
            elseif current_set(17)==current_set(7)
                Pred_h = max([current_set(13) current_set(14)]);
                Pred_l = min([current_set(13) current_set(14)]);
            end
        else
            if pred_method==1
                sorted_pixels=sort(current_set(3:6),'descend');
                Pred_h=round(sum(sorted_pixels(1)));
                Pred_l=round(sum(sorted_pixels(4)));
            elseif pred_method==2
                sorted_pixels=sort(current_set(3:6),'descend');
                Pred_h=round(sum(sorted_pixels(1:2))/2);
                Pred_l=round(sum(sorted_pixels(3:4))/2);
            elseif pred_method==3
                sorted_pixels=sort(current_set(3:6),'descend');
                Pred_h=round(sum(sorted_pixels(1:3))/3);
                Pred_l=round(sum(sorted_pixels(2:4))/3);
            elseif pred_method==4
                Pred_h=round(sum(current_set(3:6))/4);
                Pred_l=Pred_h-1;
            else
                pause;
            end
        end
        if Pred_h==Pred_l
            Pred_l=Pred_l-1;
        end
        
        pe=mod_P(loc_y)-Pred_l;
        pixel=mod_P(loc_y);
        if message_length >= ec+1
            [ec, pixel, re_m]=prediction(ec,pixel,pe,-1);
            if flag==1
                if i1==counter
                    if isempty(re_m)==0
                        ec = ec-1;
                    end
                else
                    if isempty(re_m)==0
                        re_message(ec)=re_m;
                    end
                end
            else
                if isempty(re_m)==0
                    re_message(ec)=re_m;
                end
            end
            pe=pixel-Pred_h;
            
            if message_length ~= ec
                [ec, pixel, re_m]=prediction(ec,pixel,pe,1);
                if isempty(re_m)==0
                    re_message(ec)=re_m;
                end
            else
                [ec, pixel, re_m]=prediction(ec,pixel,pe,1);
                if message_length ~= ec
                    ec=ec-1;
                end
            end
        else
            break
        end
        location(i1)=loc_y;
        temp(i1)=pixel;
        final_set=i1;
    end
end
if final_set~=0
    mod_P(location(1:final_set))=temp(1:final_set);
end

end

function [ec, pixel,re_m]=prediction(ec,pixel,pe,direction)
re_m=[];
if direction ==1
    if pe == 0
        ec=ec+1;
        re_m=0;
    elseif pe == 1
        ec=ec+1;
        re_m=1;
        pixel=pixel-1;
    elseif pe > 1
        pixel=pixel-1;
    end
else
    if pe == 0
        ec=ec+1;
        re_m=0;
    elseif pe == -1
        ec=ec+1;
        re_m=1;
        pixel=pixel+1;
    elseif pe < -1
        pixel=pixel+1;
    end
end
end
