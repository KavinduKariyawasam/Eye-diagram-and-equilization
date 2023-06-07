clear; clc;
N = 10^6;              % Number of bits
SNR = [0:10];           % Eb/N0 values
K = 4;                  % Number of tap settings

for i = 1:length(SNR)
   Bit_Stream = rand(1,N)>0.5;           % Generating random binary sequence 
   BPSK_Symbols = 2*Bit_Stream-1;        % Mapping to BPSK symbols  0 -> -1 and 1 -> 1
   
   % Defining multipath channel impulse response
   h = [0.3 0.9 0.4]; 
   
   %Generating received signal by convolving
   Received_Signal = conv(BPSK_Symbols,h);  
   
   % Adding White Gaussian noise
   Noise = 1/sqrt(2)*[randn(1,N+length(h)-1) + 1i*randn(1,N+length(h)-1)];
   Signal_With_Noise = Received_Signal + 10^(-SNR(i)/20)*Noise;                % Noise addition

   for k = 1:K
     L  = length(h);
     Toeplitz_Matrix = toeplitz([h([2:end]) zeros(1,2*k+1-L+1)], [ h([2:-1:1]) zeros(1,2*k+1-L+1) ]);
     d  = zeros(1,2*k+1);
     d(k+1) = 1;
     Coeff  = [inv(Toeplitz_Matrix)*d.'].';

     % Matched filter
     yFilt = conv(Signal_With_Noise,Coeff);
     yFilt = yFilt(k+2:end); 
     yFilt = conv(yFilt,ones(1,1));          % Performing convolution
     ySamp = yFilt(1:1:N);                   % Sampling
   
     % receiver - hard decision decoding
     E_Bits = real(ySamp)>0;

     % Counting number of bit errors
     Num_Errors(k,i) = size(find([Bit_Stream- E_Bits]),2);
     
   end
end
length(Bit_Stream)
disp(Num_Errors);

simBer = Num_Errors/N; % simulated ber
theoryBer = 0.5*erfc(sqrt(10.^(SNR/10))); % theoretical ber

% plotting
close all
figure
semilogy(SNR,simBer(1,:),'bs-')
hold on
semilogy(SNR,simBer(2,:),'gd-')
semilogy(SNR,simBer(3,:),'ks-')
semilogy(SNR,simBer(4,:),'mx-')
semilogy(SNR, theoryBer, 'k-')
axis([0 10 10^-3 0.5])
grid on
legend('sim-3tap', 'sim-5tap','sim-7tap','sim-9tap','AWGN');
xlabel('Eb/No, dB');
ylabel('Bit Error Rate');
title('Bit error probability curve for BPSK in ISI with ZF equalizer');

