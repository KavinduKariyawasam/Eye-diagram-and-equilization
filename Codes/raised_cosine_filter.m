function h = raised_cosine_filter(alpha, Fs)
    % Define time vector
    t = -Fs:1/Fs:Fs;

    % Generate sinc filter
    sinc_filter = sinc(t);

    % Compute cosine component
    cos_num = cos(alpha*pi*t);
    cos_den = (1 - (2*alpha*t).^2);
    cos_den_zero = find(abs(cos_den) < 10^-10);
    cos_op = cos_num./cos_den;
    cos_op(cos_den_zero) = pi/4;

    % Compute raised cosine filter
    h = sinc_filter .* cos_op;
end
