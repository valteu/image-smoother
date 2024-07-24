function process_and_save_image(imagePath)
    if ~isfile(imagePath)
        error('File does not exist.');
    end
    
    Img = im2double(imread(imagePath));
    
    [~, name, ~] = fileparts(imagePath);
    
    if contains(lower(name), 'flower')
        lambda = 1;
        iter = 4;
        p = 0.8;
        eps = 0.0001;
        
        Smoothed = ILS_LNorm(Img, lambda, p, eps, iter);
        Diff = Img - Smoothed;
        ImgE = Img + 3 * Diff;
        
        imwrite(Smoothed, strcat(name, '_smoothed.png'));
        imwrite(ImgE, strcat(name, '_enhanced.png'));

    elseif contains(lower(name), 'clip_art')
        lambda = 30;
        gamma = 10/255;
        iter = 10;
        
        Smoothed = ILS_Welsch(Img, lambda, gamma, iter);
        
        imwrite(Smoothed, strcat(name, '_smoothed.png'));
        
    else
        error('Unknown image type. The image name should contain "flower" or "clip_art".');
    end
end

function output = ILS_LNorm(Img, lambda, p, eps, iter)
    output = Img;
end

function output = ILS_Welsch(Img, lambda, gamma, iter)
    output = Img;
end
