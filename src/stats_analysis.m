%% one vs all features distance from intended signal
mpc_all_features = trial1_allFeatures_mpc(~isnan(trial1_allFeatures_mpc));
mpc_all_features_ref = trial1_allFeatures_mpc_sinusoid(:,1:length(mpc_all_features));
mpc_all_features_dif = (mpc_all_features_ref(2,:) - mpc_all_features);

mpc_all_features_dif = (mpc_all_features_dif - min(mpc_all_features_dif))./(max(mpc_all_features_dif) - min(mpc_all_features_dif));

mpc_one_feature = trial1_oneFeature_mpc(~isnan(trial1_oneFeature_mpc));
mpc_one_feature_ref = trial1_oneFeature_mpc_sinusoid(:,1:length(mpc_one_feature));
mpc_one_feature_dif = (mpc_one_feature_ref(2,:) - mpc_one_feature);

mpc_one_feature_dif = (mpc_one_feature_dif - min(mpc_one_feature_dif))./(max(mpc_one_feature_dif) - min(mpc_one_feature_dif));

[p, h, stats] = signrank(mpc_all_features_dif, mpc_one_feature_dif(1:length(mpc_all_features_dif)));

difs1 = [mpc_all_features_dif', mpc_one_feature_dif(1:length(mpc_all_features_dif))'];

boxplot(difs1);
%% simple mpc vs pid distance from intended signal

mpc_all_features = trial1_allFeatures_mpc(~isnan(trial1_allFeatures_mpc));
mpc_all_features_ref = trial1_allFeatures_mpc_sinusoid(:,1:length(mpc_all_features));
mpc_all_features_dif = (mpc_all_features_ref(2,:) - mpc_all_features);

mpc_all_features_dif = (mpc_all_features_dif - min(mpc_all_features_dif))./(max(mpc_all_features_dif) - min(mpc_all_features_dif));

pid_all_feature = trial1_allFeatures_pid(~isnan(trial1_allFeatures_pid));
pid_all_feature_ref = trial1_allFeatures_pid_sinusoid(:,1:length(pid_all_feature));
pid_all_feature_dif = (pid_all_feature_ref(2,:) - pid_all_feature);

pid_all_feature_dif = (pid_all_feature_dif - min(pid_all_feature_dif))./(max(pid_all_feature_dif) - min(pid_all_feature_dif));

[p2, h2, stats2] = signrank(mpc_all_features_dif, pid_all_feature_dif(1:length(mpc_all_features_dif)));

difs2 = [mpc_all_features_dif', pid_all_feature_dif(1:length(mpc_all_features_dif))'];

boxplot(difs2);