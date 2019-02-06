classdef GazeDetector < handle
%EYEDETECTOR Summary of this class goes here
%   Detailed explanation goes here

    properties
        Features
        NumFeatures
        GazeSVM
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
        function obj = GazeDetector(features, seed)
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

            obj.initializeGazeDetection();
        end

        function initializeGazeDetection(obj)
            separator = '/';
            if ispc
                separator = '\';
            end
     
            labels = xlsread(strcat('EyesDataset', separator, 'Miram.xlsx'));
            labels = labels(:, 5);    % Nomes ens interessa la 5a columna
            labels = labels';

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

            crop_size = [25, 80];   % Num rows, num cols; per imresize
            % block_size = [2, 2]   % no cal pq va per defecte

            % Ha d'anar en format de matriu
            feature_training = zeros(size(obj.TrainIndexes,2), obj.NumFeatures);

            y_labels = false(1, size(obj.TrainIndexes,2));
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
                y_labels(y_labels_index) = labels(obj.TrainIndexes(i));
                y_labels_index = y_labels_index + 1;
            end

            % Entrenar el classificador SVC
            obj.GazeSVM = fitcsvm(feature_training, y_labels);
        end

        function [mean_error, confusion] = testClassifier(obj)
            crop_size = [25, 80];   % Num rows, num cols; per imresize
            feature_vector = zeros(size(obj.TestIndexes, 2), obj.NumFeatures);
            
            separator = '/';
            if ispc
                separator = '\';
            end
            a = dir(strcat('EyesDataset', separator, '*.pgm'));
            labels_dataset = xlsread(strcat('EyesDataset', separator, 'Miram.xlsx'));
            labels_dataset = labels_dataset(:, 5);    % Nomes ens interessa la 5a columna
            labels_dataset = labels_dataset';
            
            labels = false(1, size(obj.TestIndexes, 2));

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
                labels(i) = labels_dataset(obj.TestIndexes(i));
            end

            pred = predict(obj.GazeSVM, feature_vector);
            failures = 0;
            
            for i = 1 : size(obj.TestIndexes, 2)
                if labels(i) ~= pred(i)
                    failures = failures + 1;
                end
            end
            mean_error = failures / size(obj.TestIndexes, 2);
            confusion = confusionmat(labels,pred);

        end

        function prediction = predictData(obj, data)
            prediction = predict(obj.GazeSVM, feature_extractor(data, obj.Features));
        end
    end
end

