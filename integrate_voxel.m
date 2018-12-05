len = length(timearray);
volume = zeros(len,1);
T_mean = zeros(len,1);
for i = 1:len
    ROI = TrackingT(1:30,1:30,i);
    T_mean(i) = mean(mean(ROI));
    diff = T_mean(i)-ROI;
    volume(i) = sum(sum(diff(diff>0)));
end
%plot(timearray,volume)
%figure()
%plot(timearray,T_mean)

%% filtering
tmax = 3;
fs = len/((timearray(len)-timearray(1))/1000);
win_len = floor(2*tmax*fs+1);
w = zeros(floor(len/win_len),win_len);
gw = gausswin(win_len);
for i = 1:floor(len/win_len)
    w(i,:) = (volume((i-1)*win_len+1:i*win_len));%.*gw;
    w(i,:) = w(i,:)-mean(w(i,:));
    w(i,:) = w(i,:)./std(w(i,:));
end

R = zeros(floor(len/win_len),win_len*2-1);
max_freq = zeros(floor(len/win_len),1);
for i = 1:floor(len/win_len)
    R(i,:) = xcorr(w(i,:),w(i,:));
    fR = fft(R(i,:));
    [max_value,max_index] = max(abs(fR(1:length(fR))));
    max_freq(i) = max_index;
end
freq = (max_freq-1)*(fs/(length(fR)-1));

time_gt = timearray(gt);
freq_gt = 1000./(time_gt(2:end)-time_gt(1:end-1));
freq_resample = resample(freq,length(freq_gt),length(freq));
figure()
plot(freq_gt(1:end))
hold on
plot(freq_resample)
hold off
error = norm(freq_gt-freq_resample)/length(gt);