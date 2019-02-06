function [surf_features] = extract_surf(eyes_image)
    surf_points = detectSURFFeatures(eyes_image, 'NumOctaves', 1);
    [features, svp] = extractFeatures(eyes_image, surf_points, 'Method', 'SURF');
    if surf_points.Count == 0
        surf_features = zeros(1, 64);
    else
        if surf_points.Count == 1
            surf_features = features;
        else
            surf_features = features(1, :);
        end
    end
end

