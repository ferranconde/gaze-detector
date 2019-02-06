function [lbp_features] = extract_lbp(eyes_image)
    cell_size = [8, 8];
    lbp_features = extractLBPFeatures(eyes_image, 'CellSize', cell_size);
end

