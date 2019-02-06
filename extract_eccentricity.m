function [eccentricity] = extract_eccentricity(eyes_image)
    I = imbinarize(eyes_image);
    I = imfill(not(I), 'holes');
    [IH, IW] = size(I);
    I_lefteye = imcrop(I, [1, 1, IW/2, IH]);
    stats = regionprops(I_lefteye, 'Eccentricity', 'Area');
    max_area = 0;
    eye_index = 0;
    % We sort by area so we only get the biggest one  
    for j = 1:size(stats)
       if stats(j).Area > max_area
           max_area = stats(j).Area;
           eye_index = j;
       end
    end
    
    if (eye_index ~= 0)
        eccentricity = stats(eye_index).Eccentricity; 
    else
        eccentricity = 0;
    end
end

