function plotEMGFeatures(EMGFeatures, fig)
    figure(fig);
    plot(EMGFeatures);
    legend(["Feature 1", "Feature 2", "Feature 3", "Feature 4", "Feature 5"], "Location", "northeast");
end

