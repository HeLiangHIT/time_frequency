function [individual_tracks,tf_tracks]=tracks_MCQmethod(tf,Fs,delta_limit,min_length,MAX_NO_PEAKS)
%-------------------------------------------------------------------------------
% 出生-死亡频率估计算法
% tracks_IF_MCQ_method: estimate tracks (IF laws) using method in [1]
%
% Syntax: tf_tracks=tracks_IF_MCQ_method(tf,Fs,delta_limit,min_length,MAX_NO_PEAKS)
%
% Inputs: 
%     tf          - time-frequency distribution
%     Fs          - sampling frequency
%     delta_limit - limit to search for next point in track
%     min_length  - track must be of minimum length (otherwise is rejected)
%     MAX_NO_PEAKS - maximum number of selected peaks per time-slice
%
% Outputs: 
%     individual_tracks - each track separately (cell)
%     tf_tracks         - time-frequency location of tracks (matrix)
%
% Example:
%    b=load('synth_signal_example_0dB.mat');
%    N=1024; Ntime=512; 
%    x=b.x(1:N); Fs=b.Fs;
%
%    tf=gen_TFD_EEG(x,Fs,Ntime,'sep');
%    [it,tf_tracks]=tracks_MCQmethod(tf,Fs,100,100);
%
%    t_scale=(length(x)/b.Fs/Ntime);  f_scale=(1/size(tf,2))*(Fs/2);
%    figure(1); clf; hold all; 
%    for n=1:length(it)
%          plot(it{n}(:,1).*t_scale,it{n}(:,2).*f_scale,'k+'); 
%    end
%    xlabel('time (seconds)'); ylabel('frequency (Hz)');
%    xlim([0 N/Fs]);
%     
%
% [1] McAulay, R. J., & Quatieri, T. F. (1986). Speech analysis/synthesis based on a
% sinusoidal representation. IEEE Transactions on Acoustics, Speech, and Signal
% Processing, 34(4), 744鈥?54. 

% John M. O' Toole, University of Deusto
% Started: 29-01-2012
%-------------------------------------------------------------------------------


if(nargin<3 || isempty(delta_limit)) delta_limit=4; end
if(nargin<4 || isempty(min_length)) min_length=[]; end
if(nargin<5 || isempty(MAX_NO_PEAKS)), MAX_NO_PEAKS=10; end




DBverbose=0;


[Ntime,Nfreq]=size(tf);


%---------------------------------------------------------------------
% 0 SET the parameters for the method:
%---------------------------------------------------------------------
mq_params.MAX_NO_PEAKS=MAX_NO_PEAKS; % max. number of peaks to extract
mq_params.delta=delta_limit;  % and then index

% NOT using any of these parameters here (0=off):
mq_params.VOCODER_harmonic_peak_picking=0; 
mq_params.VOCODER_f0_estimate=0.5; 
mq_params.VOCODER_spec_amplitude_compression=0; % before selecting peaks compress amps.
mq_params.VOCODER_spec_amplitude_compress_factor=0.5;  % <=1 and >0
mq_params.Nfreq=Nfreq; 
mq_params.Fs=Fs; 




%---------------------------------------------------------------------
% estimate the IFs and return as 'tracks'
%---------------------------------------------------------------------
if(DBverbose) disp('-- STARTING: extracting tracks --'); end
[tf_tracks,individual_tracks]=getIF_tracks(tf,mq_params);
if(DBverbose) disp('-- FINISHED: extracting tracks --'); end

if(isempty(individual_tracks))
    return;
end

%---------------------------------------------------------------------
% 2.A) MODIFY: remove tracks of length less than three
%      as with birth and death this is only really a 1-point peak
%---------------------------------------------------------------------
if(~isempty(min_length))
    N_tracks=length(individual_tracks); nmat=[];
    for n=1:N_tracks
        if(length(individual_tracks{n})<=min_length)
            nmat=[nmat, n];
        end
    end
    individual_tracks(nmat)=[];
    
end






function [tracks,individual_tracks]=getIF_tracks(S,mq_params)
%-------------------------------------------------------------------------------
% Extract IF and IA from multicomponent signals using the McAuley-Quatieri method
%
%
% Values in matrix 'tracks' mean:
%     0=no track
%     1=continuing track
%     0.5=birth of track
%     -1=death of track
% 
% STARTED: 11-03-2011
%-------------------------------------------------------------------------------
IFs=[]; IAs=[];
[Ntime,Nfreq]=size(S);
DBplot=0;
DB=0;  DBh=0;


tracks=[]; individual_tracks=[];



sin_params=zeros(Ntime,Nfreq);
tracks=zeros(Ntime,Nfreq);
itracks_info=zeros(Ntime,Nfreq);
individual_tracks={};

% which peak-picking method to use:
% either A) using the 1st and 2nd order derivate
% or     B) pick max. in potential harmonic window (need f0 estimate)
method_peaks=[]; k0_estimate=[];
if(mq_params.VOCODER_harmonic_peak_picking)
    method_peaks='harmonic_peaks';
    k0_estimate=mq_params.VOCODER_f0_estimate*(2*mq_params.Nfreq/mq_params.Fs);
end
% compress amplitude when picking peaks so as not to be dazzled by the formats
amplitude_compress_factor=[];
if(mq_params.VOCODER_spec_amplitude_compression)
    amplitude_compress_factor=mq_params.VOCODER_spec_amplitude_compress_factor;
end


for k=1:Ntime

    % if spectrogram of maybe a TFD:
    if(~isreal(S))
        Smag_k=abs(S(k,:)).^2;
    else
        Smag_k=S(k,:);
    end
    
    % 1. peak picks (using the 1st and 2nd order derivate)
    if(~isempty(amplitude_compress_factor))
        Smag_k_peaks=(Smag_k./max(Smag_k)).^amplitude_compress_factor;
    else
        Smag_k_peaks=Smag_k;
    end
    
    fbin_k=peakfind(Smag_k_peaks,method_peaks,k0_estimate);
    findex_k=find(fbin_k==1);

    
    % 1b. limit number of peaks:
    if(length(findex_k)>mq_params.MAX_NO_PEAKS)
        [msort,isort]=sort(Smag_k(findex_k),'descend');
        findex_k=findex_k(isort(1:mq_params.MAX_NO_PEAKS));
        findex_k=sort(findex_k);
    end
    Nfmax=length(findex_k);
    
    if(DBplot)
        figure(1); clf;
        plot(1:Nfreq,Smag_k,'-');
        hold on;
        plot(findex_k,Smag_k(findex_k),'r+');
        dispVars('Hit return to ...');
% $$$         pause(0.4); 
        pause(0.1); 
    end


    
    %---------------------------------------------------------------------
    % Do the track 'birth-death' analysis as proposed by McA and Q.
    %---------------------------------------------------------------------
    findex_k_copy=findex_k;
    
    
    %---------------------------------------------------------------------
    % For first frame (i.e. k=1), give birth to all tracks:
    %---------------------------------------------------------------------
    if(k==1)
        if(DB) dispVars(length(individual_tracks)); end 
        for m=1:Nfmax
            individual_tracks{m}=[1,findex_k(m)];
            itracks_info(1,findex_k(m))=m;
        end

    else
        m=1:Nfmax;
        for n=1:Nfmax_previous;

            % Should never be (but could if monotonic increasing):
%             if(length(findex_k)==0)
%                 figure(1); clf;
%                 plot(1:Nfreq,Smag_k,'-');
%                 hold on;
%                 plot(findex_k,Smag_k(findex_k),'r+');
%             end

            % search through all possible values and find the minimum distance between frequency
            % maximum for this and the previous frame:
            freq_distance=abs(findex_k_previous(n)-findex_k(m));
            [smallest_freq_distance,ismallest_freq_distance]=min(freq_distance);
            if(DB) 
                dispVars(smallest_freq_distance,ismallest_freq_distance,Nfmax); 
                dispVars(length(m),length(freq_distance));
            end

            %---------------------------------------------------------------------
            % Check for candidate match 
            % between f_n^k and f_m^{k+1}
            %---------------------------------------------------------------------
            % if no match can be found for f_n^k:
            if(smallest_freq_distance>mq_params.delta)
                % KILL here
                [tracks,findex_k_previous,individual_tracks,itracks_info]= ...
                    kill_tracks(tracks,k,n,findex_k_previous,individual_tracks,itracks_info);
            else

                % if the distance is ok, then let this be the candidate
                findex_candidate_k=findex_k(ismallest_freq_distance);
                if(DBh) dispVars(findex_candidate_k); end
                
                % check to see if there are other frequencies in the previous frame
                % that would give a better fit
                n_not_taken=(n+1):Nfmax_previous;
                if(isempty(n_not_taken) | isempty(findex_candidate_k))
                    % do this if at last n, i.e. n=Nfmax_previous
                    freq_distance_check=1e10;
                else
                    freq_distance_check=abs(findex_k_previous(n_not_taken)- ...
                                            findex_candidate_k);
                    [freq_distance_check,ifreq_distance_check]= ...
                        min(freq_distance_check);
                end
                if(DBh) dispVars(freq_distance_check,smallest_freq_distance); end
                if(DBh)
                    dispVars('f_{n}^k',findex_k_previous(n));                    
                    dispVars('f_{n+1}^k',findex_k_previous(n+1));
                    dispVars('f_{n+1}^k',findex_k_previous(ifreq_distance_check));
                    dispVars('f_m^{k+1}',findex_k(ismallest_freq_distance));
                end


                % if this distance is small enough between f_n^{k-1} and f_m^k then
                % MATCH
                if(freq_distance_check>=smallest_freq_distance)
                    [tracks,findex_k_previous,findex_k,individual_tracks,itracks_info]= ...
                        match_tracks(tracks,k,n,ismallest_freq_distance, ...
                                     findex_k_previous,findex_k,individual_tracks,itracks_info);
                    
                else
                    % otherwise MATCH f_{n+1}^{k-1} to f_m^k
                    [tracks,findex_k_previous,findex_k,individual_tracks,itracks_info] = ...
                        match_tracks(tracks,k,n+1,ismallest_freq_distance, ...
                                     findex_k_previous,findex_k,individual_tracks,itracks_info);
                    
                end                    
            end
            
            %---------------------------------------------------------------------
            % If f_n^k has not been matched or killed then check for match with 
            % f_{m-1}^{k+1}  (assuming f_{m-1}^{k+1} unmatched) 
            %---------------------------------------------------------------------
            if(findex_k_previous(n)~=0 & ismallest_freq_distance>1)
                
                findex_candidate_minus1=findex_k(ismallest_freq_distance-1);
                if(findex_candidate_minus1~=0)

                    fdistance=abs(findex_candidate_minus1-findex_k_previous(n));

                    % KILL if distance is too large
                    if(fdistance>mq_params.delta)
                        [tracks,findex_k_previous,individual_tracks,itracks_info]= ...
                            kill_tracks(tracks,k,n,findex_k_previous, ...
                                        individual_tracks,itracks_info);
                         
                    elseif(fdistance<=mq_params.delta)
                        % if the distance is ok, then MATCH:
                        [tracks,findex_k_previous,findex_k,individual_tracks,itracks_info] = ...
                            match_tracks(tracks,k,n,ismallest_freq_distance-1, ...
                                         findex_k_previous,findex_k,individual_tracks,itracks_info);

                    end
                end
            end
            
        end % end of for n=1,....,Nfmax_previous
            

            %--------------------------------------------------------------------- 
            % Extra step to see if any peaks in f_n^k are not been assigned. If so, 
            % then kill
            %---------------------------------------------------------------------
            f_n_k_left=find(findex_k_previous>0);
            if(~isempty(f_n_k_left))
                [tracks,findex_k_previous,individual_tracks,itracks_info]= ...
                    kill_tracks(tracks,k,f_n_k_left,findex_k_previous,individual_tracks,itracks_info);
            end
            

            %---------------------------------------------------------------------
            % Also, if there are peaks unassigned in f_m^{k+1}, then give birth:
            %---------------------------------------------------------------------
        % if, after iterating over n, there are some unmatched frequency values in
        % frame k+1
        index_fk_unmatched=find(findex_k>0);
        % (BIRTH)
        [tracks,findex_k,individual_tracks,itracks_info]=...
            birth_tracks(tracks,k,index_fk_unmatched,findex_k,individual_tracks,itracks_info);

    end % end of if k>1

    
    findex_k_previous=findex_k_copy;
    Nfmax_previous=Nfmax;
    findex_k=0; Nfmax=0;
end


% For all tracks for first frame to be 'birthed':
% (ignoring kill tracks)
tracks(1,find(tracks(1,:)==1))=0.5;


        





function [tracks,f_k_previous,f_k,sep_tracks,itracks_info]=...
    match_tracks(tracks,k,n,m,f_k_previous,f_k,sep_tracks,itracks_info)
%---------------------------------------------------------------------
% MATCH between two frequency components (peaks) 
%---------------------------------------------------------------------
try
    a1=f_k_previous(n);
    a2=f_k(m);    
catch
    return;
end

if(a1~=0 & a2~=0)
    tracks(k-1,f_k_previous(n))=1;
    tracks(k,f_k(m))=1;
    
    itrack=itracks_info(k-1,f_k_previous(n));
    itracks_info(k,f_k(m))=itrack;

    % STORE track into separate cell:
    sep_tracks{itrack}=[ sep_tracks{itrack}; [k,f_k(m)] ];
    
    % eliminate these from future searches:
    f_k_previous(n)=0;
    f_k(m)=0; 
end



function [tracks,f_k_previous,sep_tracks,itracks_info]=...
    kill_tracks(tracks,k,n,f_k_previous,sep_tracks,itracks_info)
%---------------------------------------------------------------------
% KILL between two frequency components (peaks) 
%---------------------------------------------------------------------
for in=1:length(n)
    nn=n(in);
    
    tracks(k-1,f_k_previous(nn))=1;
    tracks(k,f_k_previous(nn))=-1;
    
    itrack=itracks_info(k-1,f_k_previous(nn));
    itracks_info(k,f_k_previous(nn))=itrack;
    

    % STORE individual track:
    sep_tracks{itrack}=[ sep_tracks{itrack}; [k,f_k_previous(nn)] ];

    % and remove this from further examination:
    f_k_previous(nn)=0;
end




function [tracks,f_k,sep_tracks,itracks_info]=...
    birth_tracks(tracks,k,m,f_k,sep_tracks,itracks_info)
%---------------------------------------------------------------------
% BIRTH between two frequency components (peaks) 
%---------------------------------------------------------------------
tracks(k-1,f_k(m))=0.5;
tracks(k,f_k(m))=1;

% STORE individual track:
for im=1:length(m)
    L=length(sep_tracks);
    f_k_m=f_k(m(im));
    
    itracks_info(k-1,f_k_m)=L+1;
    itracks_info(k,f_k_m)=L+1;    

    sep_tracks{L+1}=[ [k-1,f_k_m]; [k,f_k_m] ];
end


f_k(m)=0;




function y=peakfind(x,METHOD,k0_estimate);
%---------------------------------------------------------------------
% PEAKFIND(X) picks the peaks of a sequence.
% using first and second derivate 
%---------------------------------------------------------------------
if(nargin<2 || isempty(METHOD)) METHOD='diff'; end
N=length(x);
y=zeros(N,1);


switch METHOD
  case 'harmonic_peaks'
    win_width=4;

    w_l=0; end_freq=0;
    k_lower=floor( k0_estimate-(k0_estimate/win_width) );
    k_upper=floor( k0_estimate+(k0_estimate/win_width) );
    
    
    while(end_freq==0)
        n_window=(w_l+k_lower):(w_l+k_upper);
        
        if(n_window(end)>length(x))
            end_freq=1;
        else
            [xmax,imax]=max(x(n_window));
            w_l=n_window(imax);        
            y(w_l)=1;
        end
    end
    
    
  case 'diff'
    y(2:N-1)=sign(-sign(diff(sign(diff(x)))+0.5)+1);
    
  otherwise
    error('which peak-picking method to use?');
end

