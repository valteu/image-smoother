%  ---------------------- Input------------------------
%  F:              input image, can be gray image or RGB color image
%  lambda:     \lambda in Eq.(1), control smoothing strength
%  p:              the power norm in the Charbonnier penalty in Eq. (2)
%  eps:          the small constant number in the Charbonnier penalty in Eq. (2)
%  iter:           iteration number of the ILS in Eq. (8)

%  ---------------------- Output------------------------
%  U:             smoothed image

function U =ILS_LNorm_GPU(F, lambda, p, eps, iter)

gamma = 0.5 * p - 1;
c =  p * eps^gamma;

[N, M, D] = size(F);
sizeI2D = [N, M];

otfFx = psf2otf_Dx_GPU(sizeI2D); % equal to otfFx = psf2otf(fx, sizeI2D) where fx = [1, -1];
otfFy = psf2otf_Dy_GPU(sizeI2D); % equal to otfFy = psf2otf(fy, sizeI2D) where fy = [1; -1];

Denormin = abs(otfFx).^2 + abs(otfFy ).^2;
Denormin = repmat(Denormin, [1, 1, D]);
Denormin = 1 + 0.5 * c * lambda * Denormin;

F = gpuArray(single(F));      % very important to reduce the computational cost
U = F;                                % smoothed image

for k = 1: iter
    
    Normin1 = fft2(U);
    
    % Intermediate variables \mu update, in x-axis and y-axis direction
    u_h = [diff(U,1,2), U(:,1,:) - U(:,end,:)];
    u_v = [diff(U,1,1); U(1,:,:) - U(end,:,:)];
        
    mu_h = c .* u_h - p .* u_h .* (u_h .* u_h + eps) .^ gamma;
    mu_v = c .* u_v - p .* u_v .* (u_v .* u_v + eps) .^ gamma;
    
    % Update the smoothed image U
    Normin2_h = [mu_h(:,end,:) - mu_h(:, 1,:), - diff(mu_h,1,2)];
    Normin2_v = [mu_v(end,:,:) - mu_v(1, :,:); - diff(mu_v,1,1)];
    
    U = (Normin1 + 0.5 * lambda * (fft2(Normin2_h + Normin2_v))) ./ Denormin;
    U = real(ifft2(U));
    
end

U = gather(U);
