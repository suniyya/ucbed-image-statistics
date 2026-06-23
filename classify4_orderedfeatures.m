% boop = [19 ,20, 21, 22, 23, 24, 25, 27, 28, 29, 30, 31, 32, 33, 35, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48]; 
% 17 + 18 done so left out of boop
% check 26

boop = [19];


for b=1:length(boop)
    subj = boop(b);

    %path = 'C:\Users\BEAR_Cub\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
    %path = 'C:\Users\Bear Lab\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
    path = 'C:\Users\7piec\Box\00_BEAR_Lab\Projects\Eden Winslow\Ultrasound Features\Patch Data Saved\Stats by Patch';
    
    if ~exist(path, 'dir')
        error('Invalid file path')
    end
    
    %subj = 23;
    subjectTag = sprintf('SHR%03d', subj);
    %newPatches = ["400", "900", "1225", "1764", "3136", "3600"]; %running for additional patches
    newPatches = ["100", "225", "400", "900", "1225", "1600", "3600", "4900"];
    files = dir(fullfile(path, '*.mat'));  % Get all .mat files
    nReps = 50;
    
    for file = 1:length(files)
        fileName = files(file).name;
        %disp(fileName)
    
        if contains(fileName, subjectTag) && any(contains(fileName, newPatches)) % find files for the given subject number and load them one by one
            %disp('yes')
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
                rank = [];
                allFeatures = 1:numFeatures;
                accuraciesPerStep = zeros(maxFeatures, 1);
                allAccuracies = nan(numFeatures, 1);
                selectedFeaturesHistory = zeros(1, maxFeatures);
            
                for step = 1:maxFeatures % add one feature at a time

                    %currentSet = allFeatures(1:step); % if we want to be adding features as we go
                    currentSet = allFeatures(step); % if we want class acc for one feature at a time

%                     bestMeanAcc = -inf;
%                     bestFeature = NaN;
%                 
%                     candidates = setdiff(allFeatures, selected); % identifying the features that haven't been selected yet
%                 
%                     for candidate = candidates % looping through remaining features
%                         currentSet = [selected, candidate]; % current feature set = best features so far + each remaining feature one at a time
%                 
                        % --- Run nReps iterations ---
                        accs = zeros(nReps, 1);
                        for bloop = 1:nReps
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
                        allAccuracies(step) = meanAcc; %save all accuracies along the way
                
%                         if meanAcc > bestMeanAcc %if adding the current feature improves accuracy better than any others so far, label it as the best
%                             bestMeanAcc = meanAcc;
%                             bestFeature = candidate;
%                         end
                    %end
                
                    % === Record best ===
%                     selected = [selected, bestFeature]; % new feature set, with best new feature added
%                     rank(bestFeature) = step;
%                     accuraciesPerStep(step) = bestMeanAcc;
                    fprintf('Step %d complete\n', step);
                end

                if strcmp(arm,'arm0') == 1
                    limb = 'Aff'; 
                else
                    limb = 'UA';
                end
            
                classify_data.(arm).limb = limb;
                %classify_data.(arm).topFeatures = selected;
                %classify_data.(arm).featureRank = rank;
                classify_data.(arm).Accuracies = allAccuracies;
            
             
                fprintf('%s arm complete\n', limb);
            
            end
            
            %save(sprintf('C:\\Users\\Bear Lab\\Box\\00_BEAR_Lab\\Projects\\Eden Winslow\\Ultrasound Features\\Patch Data Saved\\Classification by Patch\\SHR%03d_%02dPatches_%02dBlockAvg_FeatureWise.mat',numSub,numPatches, classify_data.avgBy),'classify_data');
            save(sprintf('C:\\Users\\7piec\\Box\\00_BEAR_Lab\\Projects\\Eden Winslow\\Ultrasound Features\\Patch Data Saved\\Classification by Patch\\SHR%03d_%02dPatches_%02dBlockAvg_FeatureWise.mat',numSub,numPatches, classify_data.avgBy),'classify_data');
            
        end
    end
end
