function [features] = feature_extractor(eyes_image, features_names)
    features = [];
    FUNCTION_MAP = containers.Map;
    FUNCTION_MAP('Eccentricity') = @extract_eccentricity;
    FUNCTION_MAP('Hog') = @extract_hog;
    FUNCTION_MAP('Surf') = @extract_surf;
    FUNCTION_MAP('Lbp') = @extract_lbp;
    FUNCTION_MAP('Haar') = @extract_haar;
    
    for i = 1 : length(features_names)
        features = [features, feval(FUNCTION_MAP(convertStringsToChars(features_names(i))), eyes_image)];
    end
end