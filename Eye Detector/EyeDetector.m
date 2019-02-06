classdef EyeDetector < handle
%EYEDETECTOR Summary of this class goes here
%   Detailed explanation goes here

    properties
        Features
        NumFeatures
        EyeSVM
        Seed
        TrainIndexes
        TestIndexes
        SplitPercentage
        lx
        rx
        ly
        ry
    end

    methods
        function obj = EyeDetector(features, seed)
            FEATURES_SIZE = containers.Map;
            FEATURES_SIZE('Hog') = 648;
            FEATURES_SIZE('Eccentricity') = 1;
            FEATURES_SIZE('Surf') = 64;
            FEATURES_SIZE('Lbp') = 1770;
            FEATURES_SIZE('Haar') = 40;

            obj.Seed = seed;
            obj.Features = features;
            obj.NumFeatures = 0;
            obj.TrainIndexes = [];
            obj.TestIndexes = [];
            obj.SplitPercentage = 0.8;
            for i = 1 : length(features)
                obj.NumFeatures = obj.NumFeatures + FEATURES_SIZE(convertStringsToChars(features(i)));
            end

            obj.initializeEyeDetection();
        end

        function initializeEyeDetection(obj)
            separator = '/';
            if ispc
                separator = '\';
            end
            a = dir(strcat('EyesDataset', separator, '*.eye'));
            nf = size(a);
            nf = nf(1);
            obj.lx = zeros(1, nf);obj.ly = zeros(1, nf);obj.rx = zeros(1, nf);obj.ry = zeros(1, nf);
            for i = 1:nf
                filename = horzcat(a(i).folder,'/',a(i).name);
                fid = fopen(filename);
                s = textscan(fid, '%s', 1, 'delimiter', '\n');
                c = textscan(fid, '%d', 4, 'delimiter', ' ');
                obj.lx(i) = c{1}(1);obj.ly(i) = c{1}(2);obj.rx(i) = c{1}(3);obj.ry(i) = c{1}(4); 
                fclose(fid);
            end

            % Carregar retalls dels ulls
            % Hem fet proves i hem vist que, amb imatges de 108x37 surt aprox el doble
            % de features que amb imatges de 79x27.
            % Predefinim, aixi, mida de 80x25.
            a = dir(strcat('EyesDataset', separator, '*.pgm'));
            nf = size(a);
            nf = nf(1);

            rng(obj.Seed, 'twister');

            idx = randperm(nf);
            obj.TrainIndexes = idx(1:round(obj.SplitPercentage * nf));
            obj.TestIndexes = idx(round(obj.SplitPercentage * nf) + 1:end);
            ulls = cell(1, nf);
            no_ulls = cell(1, 19 * nf);

            crop_size = [25, 80];   % Num rows, num cols; per imresize
            % block_size = [2, 2]   % no cal pq va per defecte

            % Ha d'anar en format de matriu
            feature_training = zeros(20 * size(obj.TrainIndexes,2), obj.NumFeatures);

            y_labels = false(1, 20 * size(obj.TrainIndexes,2));
            y_labels_index = 1;

            for i = 1 : size(obj.TrainIndexes, 2)
                filename = horzcat(a(obj.TrainIndexes(i)).folder,separator,a(obj.TrainIndexes(i)).name);
                imatge = imread(filename);
                [imheight, imwidth] = size(imatge);  % num files, num columnes. esta be.
                % lx es refereix a l'ull esquerre (es el de la dreta de la imatge)

                bizco = int16(obj.lx(obj.TrainIndexes(i)) - obj.rx(obj.TrainIndexes(i)));

                offset = int16(round(bizco*0.25));
                % ara mateix obj.lx(i) - obj.rx(i) + 2*offset === 6*offset
                ulls{obj.TrainIndexes(i)} = imcrop(imatge, [obj.rx(obj.TrainIndexes(i)) - offset, obj.ry(obj.TrainIndexes(i)) - offset, bizco + 2*offset, 2*offset]);
                ulls{obj.TrainIndexes(i)} = imresize(ulls{obj.TrainIndexes(i)}, crop_size);

                feature_training(y_labels_index, :) = feature_extractor(ulls{obj.TrainIndexes(i)}, obj.Features);

                y_labels(y_labels_index) = true;
                y_labels_index = y_labels_index + 1;

                % Per 1 mostra d'ulls agafem 19 mostres de no-ulls
                fake = 0;
                while fake < 19
                    randomX = int16(randi([1, imwidth - bizco], 1, 1));
                    randomY = int16(randi([1, imheight - 2*offset], 1, 1));

                    distancia = ((obj.rx(obj.TrainIndexes(i)) - offset) - randomX)^2 + ((obj.ry(obj.TrainIndexes(i)) - offset) - randomY)^2;
                    if distancia > offset^2
                       % faig esta tecnica pq va molt mes rapid que fent {end+1} 
                       no_ulls{y_labels_index} = imcrop(imatge, [randomX, randomY, 6*offset, 2*offset]);
                       no_ulls{y_labels_index} = imresize(no_ulls{y_labels_index}, crop_size);

                       % Tambe extreure caracteristiques
                       feature_training(y_labels_index, :) = feature_extractor(no_ulls{y_labels_index}, obj.Features);
                       fake = fake + 1;

                       % y_train(y_train_index) = false; % no cal, ja es false
                       y_labels_index = y_labels_index + 1;
                    end
                end
            end

            % Entrenar el classificador SVC
            obj.EyeSVM = fitcsvm(feature_training, y_labels);
        end

        function [mean_error, confusion] = testClassifier(obj)
            crop_size = [25, 80];   % Num rows, num cols; per imresize
            feature_vector = zeros(size(obj.TestIndexes, 2) * 2, obj.NumFeatures);
            
            separator = '/';
            if ispc
                separator = '\';
            end
            a = dir(strcat('EyesDataset', separator, '*.pgm'));
            
            labels = true(2 * size(obj.TestIndexes, 2),1);
            labels((size(obj.TestIndexes, 2)+1):end) = false;

            % Get test features
            for i = 1 : size(obj.TestIndexes, 2)
                filename = horzcat(a(obj.TestIndexes(i)).folder,separator,a(obj.TestIndexes(i)).name);
                imatge = imread(filename);
                [imheight, imwidth] = size(imatge);  % num files, num columnes. esta be.
                % lx es refereix a l'ull esquerre (es el de la dreta de la imatge)

                bizco = int16(obj.lx(obj.TestIndexes(i)) - obj.rx(obj.TestIndexes(i)));

                offset = int16(round(bizco*0.25));
                % ara mateix obj.lx(i) - obj.rx(i) + 2*offset === 6*offset
                ulls = imcrop(imatge, [obj.rx(obj.TestIndexes(i)) - offset, obj.ry(obj.TestIndexes(i)) - offset, bizco + 2*offset, 2*offset]);
                ulls = imresize(ulls, crop_size);

                feature_vector(i, :) = feature_extractor(ulls, obj.Features);
                
                
                % No ull now
                found = false;
                while ~found
                    randomX = int16(randi([1, imwidth - bizco], 1, 1));
                    randomY = int16(randi([1, imheight - 2*offset], 1, 1));
                    
                    distancia = ((obj.rx(obj.TestIndexes(i)) - offset) - randomX)^2 + ((obj.ry(obj.TestIndexes(i)) - offset) - randomY)^2;
                    if distancia > offset^2
                       % faig esta tecnica pq va molt mes rapid que fent {end+1} 
                       no_ull = imcrop(imatge, [randomX, randomY, 6*offset, 2*offset]);
                       no_ull = imresize(no_ull, crop_size);

                       % Tambe extreure caracteristiques
                       feature_vector(i + size(obj.TestIndexes, 2), :) = feature_extractor(no_ull, obj.Features);
                       found = true;
                    end
                end
            end

            pred = predict(obj.EyeSVM, feature_vector);
            failures = 0;
            
            for i = 1 : (2 * size(obj.TestIndexes, 2))
                if labels(i) ~= pred(i)
                    failures = failures + 1;
                end
            end
            mean_error = failures / (2 * size(obj.TestIndexes, 2));
            confusion = confusionmat(labels,pred);

        end
        
        function prediction = predictData(obj, data)
            prediction = predict(obj.EyeSVM, feature_extractor(data, obj.Features));
        end
        
        function coords = findEyesCoords(obj, test_image)
            test_image = rgb2gray(test_image);
            [test_rows, test_cols] = size(test_image);
            test_crop_width = 100;
            test_crop_height = 30;

            crop_size = [25, 80];
            best_rectangle = [0, 0, 0, 0];
            best_score = -Inf;
            image_data = zeros(1, obj.NumFeatures);

            % de 5 en 5 pixels q no acabem mai
            for i = 1:5:test_rows - test_crop_height
               for j = 1:5:test_cols - test_crop_width
                   disp(i)
                   disp(j)
                  rect = [j, i, test_crop_width, test_crop_height];
                  crop_test = imcrop(test_image, rect);
                  crop_test = imresize(crop_test, crop_size);
                  image_data(1, :) = feature_extractor(crop_test, obj.Features);
                  [label, score] = predict(obj.EyeSVM, image_data);
                  if label
                      % Valorar si score es mes alta que l'anterior
                     if score > best_score
                         best_rectangle = rect;
                         best_score = score;
                     end
                  end
               end
            end
            coords = best_rectangle;
        end
    end
end

