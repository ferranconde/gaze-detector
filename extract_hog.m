function [hog_features] = extract_hog(eyes_image)
    cell_size = [8, 8];
    [hog_features, validPoints] = extractHOGFeatures(eyes_image, 'CellSize', cell_size);
end

