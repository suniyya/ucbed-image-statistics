

%path = 'C:\Users\BEAR_Cub\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
path = 'C:\Users\Bear Lab\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
subj = 25;
subjectTag = sprintf('SHR%03d', subj);
files = dir(fullfile(path, '*.mat'));  % Get all .mat files

for file = 1:length(files)
    fileName = files(file).name;

    if contains(fileName, subjectTag) % find files for the given subject number and load them one by one
        fullPath = fullfile(path, fileName);
        fprintf('Loading file: %s\n', fileName);
        load(fullPath);

        arms = {'arm0','arm1'};
        classify_data = struct(); 
        
        classify_data.subj = all_data.subj;
        classify_data.numPatch = all_data.numPatch;
        classify_data.avgBy = all_data.avgBy;
        classify_data.imgLen = all_data.imgLen; %length of crop
        classify_data.centX = all_data.centX; % center of crop (x, y)
        classify_data.centY = all_data.centY;
        
        for tempArm = arms %go through both arms
            arm = tempArm{1};
            [numTrials, numPatches, numStats] = size(all_data.(arm){1,1}.stats);
            numSub = all_data.(arm){1,1}.subj(1);
        
            % Reset variables
            maxFeatures = 10;
            numFeatures = 10;
            selected = [];
            allFeatures = 1:numFeatures;
            accuraciesPerStep = zeros(maxFeatures, 1);
            allAccuracies = nan(maxFeatures, numFeatures);
            selectedFeaturesHistory = zeros(1, maxFeatures);
        
            for step = 1:maxFeatures % add one feature at a time
                bestMeanAcc = -inf;
                bestFeature = NaN;
            
                candidates = setdiff(allFeatures, selected); % identifying the features that haven't been selected yet
            
                for candidate = candidates % looping through remaining features
                    currentSet = [selected, candidate]; % current feature set = best features so far + each remaining feature one at a time
            
                    % --- Run 100 iterations ---
                    accs = zeros(100, 1);
                    for bloop = 1:100
                        allYPred = [];
                        allYTrue = [];
        
                        allX = all_data.(arm){1,1}.stats;                  % [nTrials x 160] features
         %              Y = categorical(all_data.(arm){sub_idx}.graspname);  % Labels (grasp names)
            
                        % === Build feature matrix ===
                        filteredX = zeros(numTrials, numPatches * numel(currentSet));
                        for trial = 1:numTrials %before 8/11/25, this variable was i, but so was the outer loop... verify any classifications performed prior
                            row = [];
                            for f = currentSet
                                row = [row, squeeze(allX(trial, :, f))]; % extracting the features for each stat in this set and appending them
                            end
                            filteredX(trial, :) = row;
                        end
                        X = filteredX;
                        Y = categorical(all_data.(arm){1,1}.graspname);
            
                        % === 5-fold CV ===
                        cvp = cvpartition(Y, 'KFold', 5);
                        foldAcc = zeros(5, 1);
            
                        for fold = 1:5
                            XTrain = X(training(cvp, fold), :);
                            YTrain = Y(training(cvp, fold));
                            XTest = X(test(cvp, fold), :);
                            YTest = Y(test(cvp, fold));
            
                            mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', 5);
                            YPred = predict(mdl, XTest);
                            foldAcc(fold) = mean(YPred == YTest);
            
                            allYPred = [allYPred; YPred];
                            allYTrue = [allYTrue; YTest];
                        end
            
                        accs(bloop) = mean(foldAcc);
                    end
            
                    meanAcc = mean(accs);
                    allAccuracies(step, candidate) = meanAcc; %save all accuracies along the way
            
                    if meanAcc > bestMeanAcc %if adding the current feature improves accuracy better than any others so far, label it as the best
                        bestMeanAcc = meanAcc;
                        bestFeature = candidate;
                    end
                end
            
                % === Record best ===
                selected = [selected, bestFeature]; % new feature set, with best new feature added
                accuraciesPerStep(step) = bestMeanAcc;
                fprintf('Step %d complete, feature %d chosen\n', step, bestFeature);
            end
            if strcmp(arm,'arm0') == 1
                limb = 'Aff'; 
            else
                limb = 'UA';
            end
        
            classify_data.(arm).limb = limb;
            classify_data.(arm).topFeatures = selected;
            classify_data.(arm).Accuracies = allAccuracies;
        
         
            fprintf('%s arm complete\n', limb);
        
        end
        
        save(sprintf('C:\\Users\\Bear Lab\\Box\\00_BEAR_Lab\\Projects\\Eden Winslow\\Ultrasound Features\\Patch Data Saved\\Classification by Patch\\SHR%03d_%02dPatches_ForWrap.mat',numSub,numPatches),'classify_data');

    end
end
