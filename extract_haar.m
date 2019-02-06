function [haar_features] = extract_haar(eyes_image)
    [decomp, book] = wavedec2(eyes_image, 4, 'haar');
    approx_coefs = appcoef2(decomp, book, 'haar');
    detail_coefs = detcoef2('compact', decomp, book, 4);
    approx_coefs = reshape(approx_coefs.', 1, []);
    haar_features = [approx_coefs, detail_coefs];
end

