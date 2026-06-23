
numSubs = 1;
sub_idx = 1;

[numTrials, numPatches, numStats] = size(all_data.arm0{1,1}.stats);

arms = {'arm0','arm1'};
%arm = 'arm0';

for tempArm = arms %go through both arms
    arm = tempArm{1};
    accuracies = nan(1, 10); % [1, #stats/features]
    avgConfMat = nan(10, 10, 10);

    for im_stat_idx=1:numStats

        bigMean = nan(100,1);
        bigConfMat = nan(100,10,10);

        for bloop = 1:100 %perform the KNN classification 100 times and get the overall averages

                allYPred = [];
                allYTrue = [];
            
                allX = all_data.(arm){sub_idx}.stats;                  % [nTrials x 160] features
                Y = categorical(all_data.(arm){sub_idx}.graspname);  % Labels (grasp names)
                
                %OPTIONAL: filter to only one subject
                % subnum = 17;
                % subjectID = arm0.subj;
                % idx = (subjectID == subnum);   % subject subnum
                
                % image stats to include - alphas, gammas, bh, bd, be (not bv) and no
                % thetas
                % so take the stacked image stats, and only take cols 1, 2, 4, 5, 10, 
                % then reshape so they are a vector, temp = subset of stats. features =
                % temp(:);
                % reformat X first - X is n by k by 10. Needs to be n by 80. 
                [n, k, s] = size(allX);
                filteredX = zeros(n, numPatches);
                for i=1:n % loop through trials
                    temp = allX(i, :, im_stat_idx); % select specific stats/features for all patches
                    filteredX(i, :) = temp(:)';
                end
                
                X = filteredX;
                % Y = Y(idx);
                
                % Train-test split
                % Setup
                k = 5;  % number of neighbors for k-NN
                numFolds = 5;  % number of CV folds
                
                % Partition
                cvp = cvpartition(Y, 'KFold', numFolds);
                
                cv_accuracies = zeros(numFolds,1);  % store accuracy for each fold
                
                for fold = 1:numFolds
                    % Training and test data for this fold
                    XTrain = X(training(cvp, fold), :);
                    YTrain = Y(training(cvp, fold));
                    XTest = X(test(cvp, fold), :);
                    YTest = Y(test(cvp, fold));
                
                    % Train classifier
                    mdl = fitcknn(XTrain, YTrain, 'NumNeighbors', k);
                
                    % Predict
                    YPred = predict(mdl, XTest);
                    
                    % store all predictions and labels
                    allYPred = [allYPred; YPred];
                    allYTrue = [allYTrue; YTest];
        
                    % Calculate accuracy for this fold
                    cv_accuracies(fold) = mean(YPred == YTest);
                    [lenTest, ~] = size(XTest);
                    %disp(strcat('size of test set ', num2str(lenTest)));
                end
                
                % Report mean accuracy across folds
                meanAccuracy = mean(cv_accuracies);
                %fprintf('Mean cross-validated accuracy: %.2f%%\n', meanAccuracy*100);
                %
            
                %figure;
                %c = confusionchart(allYTrue, allYPred, 'Normalization', 'row-normalized');
                C = confusionmat(allYTrue, allYPred);
                confMat = C./sum(C,2);
                %c.FontSize = 14;
                %numSub = all_data.(arm){sub_idx}.subj(1);
                %title(strcat(arm, ' - sub ', num2str(all_data.(arm){sub_idx}.subj(1))));
        
                %confMat = c.NormalizedValues;
                bigMean(bloop) = meanAccuracy;
                bigConfMat(bloop,:,:) = confMat;
        end

        accuracies(1, im_stat_idx) = mean(bigMean, 'omitnan');
        avgConfMat(:,:,im_stat_idx) = squeeze(mean(bigConfMat,1,'omitnan'));
    end
    
    
    if strcmp(arm,'arm0') == 1
        limb = 'Aff'; 
    else
        limb = 'UA';
    end
    save(sprintf('C:\\Users\\BEAR_Cub\\Box\\00_BEAR_Lab\\Projects\\Eden Winslow\\Ultrasound Features\\Patch Data Saved\\SHR%03d_%02dPatches_ConfMat_%s.mat',numSub,numPatches,limb),'avgConfMat','accuracies')
    %close all
end




