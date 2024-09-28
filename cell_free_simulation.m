clc;
clear all;

% Main simulation function for a cell-free network system
% L = Number of APs
% K = Number of UEs
% N = Number of antennas per AP
% tau_p = Number of orthogonal pilot sequences

L = 5;  
K = 5;  
N = 4; 
tau_p = 3; 
AP_height = 20;
UE_height = 0;
noise_var = 0.001;  % Noise variance

% 1. Generate AP and UE locations
[AP_positions, UE_positions] = generate_positions(L, K, AP_height, UE_height);
plot_positions(AP_positions, UE_positions);

% 2. Calculate large-scale fading coefficients
[d_kl, beta_kl] = calculate_large_scale_fading(AP_positions, UE_positions, K, L);
disp('Distance matrix (d_kl) between UEs and APs:');
disp(d_kl);
disp('Large-scale fading coefficients (beta_kl) between UEs and APs:');
disp(beta_kl);

% 3. Generate Rayleigh fading channels
h_kl = generate_rayleigh_fading(K, L, N, beta_kl);

% 4. Assign pilots to UEs
pilot_assign = assign_pilots(K, tau_p);
disp('Pilot assignments for UEs:');
disp(pilot_assign);

% 5. Perform MMSE Channel Estimation
h_est = mmse_channel_estimation(K, L, N, h_kl, beta_kl, tau_p, noise_var);

% 6. Apply P-RZF Precoder
Dk = eye(N);  % Example diagonal matrix Dk
Pk = ones(L, 1);  % Example transmit powers
W_PRZF = partial_regularized_zero_forcing_precoder(h_est, Dk, Pk, noise_var);
disp('Partial Regularized Zero Forcing Precoder:');
disp(W_PRZF);

% 7. Calculate and compare spectral efficiency with/without precoder
% Without Precoder (Baseline)
SE_no_precoder = calculate_spectral_efficiency(h_kl, noise_var, Pk);
% With P-RZF Precoder
SE_with_precoder = calculate_spectral_efficiency_with_precoder(h_kl, W_PRZF, noise_var, Pk);
disp(['Spectral Efficiency without precoder: ', num2str(SE_no_precoder)]);
disp(['Spectral Efficiency with P-RZF precoder: ', num2str(SE_with_precoder)]);

% --- Evaluate Channel Estimation ---
[MSE, NMSE] = evaluate_channel_estimation(K, L, N, h_kl, h_est);

disp(['Total MSE for all UEs and APs: ', num2str(MSE)]);
disp(['Total NMSE for all UEs and APs: ', num2str(NMSE)]);


% --- Functions ---

% Function to generate random AP and UE positions (including height)
function [AP_positions, UE_positions] = generate_positions(L, K, AP_height, UE_height)
    AP_positions = [rand(L, 2) * 5000, ones(L, 1) * AP_height];  % APs in a 5x5 km area, height 20m
    UE_positions = [rand(K, 2) * 5000, ones(K, 1) * UE_height];  % UEs in a 5x5 km area, height 0m
end

% Function to plot AP and UE positions (3D plot)
function plot_positions(AP_positions, UE_positions)
    figure;
    scatter3(AP_positions(:,1), AP_positions(:,2), AP_positions(:,3), 'r^', 'filled'); hold on;
    scatter3(UE_positions(:,1), UE_positions(:,2), UE_positions(:,3), 'bo', 'filled');
    legend('APs', 'UEs');
    title('AP and UE Locations (3D)');
    xlabel('X Position (m)');
    ylabel('Y Position (m)');
    zlabel('Z Position (m)');
    grid on;
end

% Function to calculate large-scale fading and distance matrix (considering height)
function [d_kl, beta_kl] = calculate_large_scale_fading(AP_positions, UE_positions, K, L)
    d_kl = zeros(K, L);  % Distance matrix between UEs and APs
    beta_kl = zeros(K, L);  % Large-scale fading coefficients
    shadow_fading = normrnd(0, 4, [K, L]);  % Shadow fading

    for k = 1:K
        for l = 1:L
            % Distance calculation including the z-coordinate
            d_kl(k, l) = norm(UE_positions(k, :) - AP_positions(l, :));  
            % Large-scale fading with shadow fading
            beta_kl(k, l) = -30.5 - 36.7 * log10(d_kl(k, l)) + shadow_fading(k, l);  
        end
    end
end

% Function to generate Rayleigh fading channels
function h_kl = generate_rayleigh_fading(K, L, N, beta_kl)
    h_kl = cell(K, L);  % Channel coefficients
    for k = 1:K
        for l = 1:L
            h_kl{k, l} = (randn(N, 1) + 1j * randn(N, 1)) * sqrt(10^(beta_kl(k, l)/10));  % Rayleigh fading
        end
    end
end

% Function to assign pilots to UEs
function pilot_assign = assign_pilots(K, tau_p)
    pilot_assign = mod(1:K, tau_p) + 1;  % Assign pilots to UEs cyclically
end

% Function to perform MMSE Channel Estimation
function h_est = mmse_channel_estimation(K, L, N, h_kl, beta_kl, tau_p, noise_var)
    h_est = cell(K, L); % Estimated channel coefficients
    for k = 1:K
        for l = 1:L
            R_kl = eye(N) * beta_kl(k, l);  % Channel covariance matrix
            Psi_kl = eye(N) * noise_var + R_kl;  % Interference + noise covariance matrix
            if isempty(h_kl{k,1})
                h_est{k,l}=zeros(N,1);
            else
                h_est{k, l} = sqrt(tau_p) * R_kl / Psi_kl * h_kl{k,l};  % MMSE estimation
            end
        end
    end
end

% --- Function to evaluate MSE and NMSE ---
function [MSE_total, NMSE_total] = evaluate_channel_estimation(K, L, N, h_real, h_est)
    MSE_total = 0;
    NMSE_total = 0;
    real_norm = 0;
    for k = 1:K
        for l = 1:L
            MSE = sum(abs(h_real{k, l} - h_est{k, l}).^2) / N;
            MSE_total = MSE_total + MSE;
            real_norm = real_norm + sum(abs(h_real{k, l}).^2);
        end
    end
    NMSE_total = MSE_total / real_norm;
end

% Function to apply P-RZF
function W_PRZF = partial_regularized_zero_forcing_precoder(h_est, Dk, Pk, noise_var)
    [K, L] = size(h_est); 
    W_PRZF = cell(K, L);   
    for k = 1:K
        HSk = [];
        UE_per_AP = zeros(1, L);
        for l = 1:L
            if ~isempty(h_est{k, l})
                HSk = [HSk, h_est{k, l}]; 
                UE_per_AP(l) = size(h_est{k, l}, 2);  
            end
        end

        if isempty(HSk)  
            for l = 1:L
                W_PRZF{k, l} = zeros(size(Dk, 1), size(Dk, 2)); 
            end
            continue;
        end

        PSk = diag(Pk);

      
        regularization_term = noise_var^2 *PSk* eye(size(HSk, 2));
        Wk = Dk * HSk / (HSk' * Dk * HSk + regularization_term);

        
        col_start = 1;
        for l = 1:L
            if UE_per_AP(l) > 0
                col_end = col_start + UE_per_AP(l) - 1;
                W_PRZF{k, l} = Wk(:, col_start:col_end);  
                col_start = col_end + 1;  
            else
                W_PRZF{k, l} = zeros(size(Dk, 1), UE_per_AP(l));  
            end
        end
    end
end

% Function to calculate spectral efficiency without precoder
function SE=calculate_spectral_efficiency(h_kl, noise_var, Pk)
    [K, L]=size(h_kl);
    SINR=zeros(K, 1);  % SINR for each UE
    for k=1:K
        signal_power=0;
        interference_power=0;
        for l = 1:L
            if ~isempty(h_kl{k, l})
                % Signal power for desired user k
                signal_power = signal_power + Pk(l) * norm(h_kl{k, l})^2;
                
                % Interference power from all other UEs (simplified, without interference model)
                for j = 1:K
                    if j ~= k && ~isempty(h_kl{j, l})
                        interference_power = interference_power + Pk(l) * norm(h_kl{j, l})^2;
                    end
                end
            end
        end
        % Calculate SINR for user k
        SINR(k) = signal_power / (interference_power + noise_var);
    end
    % Calculate spectral efficiency
    SE = sum(log2(1 + SINR));  % Sum over all UEs
end

% Function to calculate spectral efficiency with P-RZF precoder
function SE = calculate_spectral_efficiency_with_precoder(h_kl, W_PRZF, noise_var, Pk)
    [K, L] = size(h_kl);
    SINR = zeros(K, 1);  % SINR for each UE
    for k = 1:K
        signal_power = 0;
        interference_power = 0;
        for l = 1:L
            if ~isempty(W_PRZF{k, l}) && ~isempty(h_kl{k, l})
                % Signal power for desired user k with precoding
                signal_power = signal_power + Pk(l) * abs(h_kl{k, l}' * W_PRZF{k, l})^2;
                
                % Interference power from all other UEs with precoding
                for j = 1:K
                    if j ~= k && ~isempty(h_kl{j, l}) && ~isempty(W_PRZF{j, l})
                        interference_power = interference_power + Pk(l) * abs(h_kl{j, l}' * W_PRZF{j, l})^2;
                    end
                end
            end
        end
        % Calculate SINR for user k with P-RZF
        SINR(k) = signal_power / (interference_power + noise_var);
    end
    % Calculate spectral efficiency with precoder
    SE = sum(log2(1 + SINR));  % Sum over all UEs
end