close all; clc; clear;

%% Task I

N = 1000;                 % Number of bits
fs = 10;                  % Sampling frequency
Tb = 1/fs;                % Bit duration
dt = 0.001;
t = 0:1/fs:999/fs;           %time vector
SNR_dB = 10;
NoisePower = 1./(10.^(0.1*SNR_dB));

%% Step 1
% Generating BPSK symbols
Bit_Stream = rand(1,N)>0.5;
BPSK_Symbols = Bit_Stream* 2 - 1;   % Mapping to BPSK symbols  0 -> -1 and 1 -> 1

%Plotting the BPSK impulse train
figure;
stem(t, BPSK_Symbols);
xlabel('Time');
ylabel('Amplitude');
title('Impulse Train representing BPSK Symbols');
ylim([-1.5 1.5])
xlim([0 5])
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;
%% Step 2
t = -fs:1/fs:fs;           %Updating the time vector
Sinc_Filter = sinc(t);     %Defining sinc pulse shaping filter

%Plotting sinc pulse
figure
plot(t, Sinc_Filter);
xlabel('Time');
ylabel('Amplitude');
title('Sinc pulse');
ylim([-0.5 1.2])
xlim([-5 5])
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

% Upsampling the BPSK sequence
t = 0:Tb:99*Tb;                     %Updating the time vector
BPSK_Symbols = upsample(BPSK_Symbols, fs);

figure;
stem(t, BPSK_Symbols(1:100)); 
xlabel('Time'); 
ylabel('Amplitude');
title('Upsampled BPSK Impulse Train');
axis([0 10 -1.2 1.2]); 
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

% Generating transmit signal by convolving with sinc pulse
Tx_Signal = conv(BPSK_Symbols, Sinc_Filter);
t = 0:Tb:(length(Tx_Signal)-1)*Tb;

%Plotting the transmit signal
figure
plot(t, Tx_Signal);
xlabel('Time');
ylabel('Amplitude');
title('Transmitted Signal');
xlim([0 50])
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

%% Step 3
%Generating the eye diagram
eyediagram(Tx_Signal, 2*fs);

%% Step 4
%Defining raised cosine filter with roll-off = 0.5
rcos_alpha5 = raised_cosine_filter(0.5, fs);
rcos_alpha1 = raised_cosine_filter(1, fs);

% Generating transmit signal by convolving with raised cosine
Tranmit_Signal1 = conv(BPSK_Symbols, rcos_alpha5);
Tranmit_Signal2 = conv(BPSK_Symbols, rcos_alpha1);

% Plotting
figure;
t = 0:Tb:(length(rcos_alpha5)-1)*Tb;
plot(t, rcos_alpha5);
grid on;
title('Raised Cosine Filter (Roll-off Factor = 0.5)');
xlabel('Time (s)');
ylabel('Amplitude');
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

% Plotting
figure;
t = 0:Tb:(length(rcos_alpha1)-1)*Tb;
plot(t, rcos_alpha1);
grid on;
title('Raised Cosine Filter (Roll-off Factor = 1)');
xlabel('Time (s)');
ylabel('Amplitude');
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

%Plotting the transmit signals
figure;                                      %with roll-off = 0.5
t = 0:Tb:(length(Tranmit_Signal1)-1)*Tb;
plot(t, Tranmit_Signal1);
xlabel('Time');
ylabel('Amplitude');
title('Transmitted Signal (Roll-off Factor = 0.5)');
xlim([0 50])
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

figure;                                     %with roll-off = 1
t = 0:Tb:(length(Tranmit_Signal2)-1)*Tb;
plot(t, Tranmit_Signal2);
xlabel('Time');
ylabel('Amplitude');
title('Transmitted Signal (Roll-off Factor = 1)');
xlim([0 50])
grid on;
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

%Generating eye diagrams
eyediagram(Tranmit_Signal1, 2*fs);          %For roll-off = 0.5
eyediagram(Tranmit_Signal2, 2*fs);          %For roll-off = 1

%% Task 2

%% Adding Noise
AWGN_TX_Sinc = awgn(Tx_Signal,SNR_dB,'measured');
AWGN_TX_roll5 = awgn(Tranmit_Signal1,SNR_dB,'measured');
AWGN_TX_roll1 = awgn(Tranmit_Signal2,SNR_dB,'measured');

%Plotting the figures
figure;
t = 0:Tb:(length(AWGN_TX_Sinc)-1)*Tb;
plot(t, AWGN_TX_Sinc);
grid on;
title('Transmit Signal with Noise (Sinc Pulse Shaping)');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 50]);
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

figure;
t = 0:Tb:(length(AWGN_TX_roll5)-1)*Tb;
plot(t, AWGN_TX_roll5);
grid on;
title('Raised Cosine Filter (Roll-off Factor = 0.5)');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 50]);
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

figure;
t = 0:Tb:(length(AWGN_TX_roll1)-1)*Tb;
plot(t, AWGN_TX_roll1);
grid on;
title('Raised Cosine Filter (Roll-off Factor = 1)');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 50]);
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 12;

% eye diagrams with noise
eyediagram(AWGN_TX_Sinc, 2*fs);           %For sinc pulse     
eyediagram(AWGN_TX_roll5, 2*fs);          %For roll-off = 0.5
eyediagram(AWGN_TX_roll1, 2*fs);          %For roll-off = 1
