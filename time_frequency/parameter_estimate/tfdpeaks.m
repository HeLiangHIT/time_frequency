function peaks = tfdpeaks (tfd,thresh)

%----------------------------------------------------------------------------------------------------------------
% Usage:    peaks = tfdpeaks(tfd, thresh)
%
%   Inputs: tfd ~ The time-frequency representation where local peaks are
%                 to be found
%           thresh ~ percentage of tfd maximum local peaks must be above
%                    to be considered a valid peak. Default = 0.005
%
%   Outputs: peaks ~ a binary image indicating the located peaks
%
% Notes: This function finds the local peaks in the time frequency
%        representation which are a above a predetermined threshold
%
% Written by: Luke Rankine ~ January 2006
%----------------------------------------------------------------------------------------------------------------

if nargin < 2
    thresh = 0.005;
end

% initialize peaks
sc1 = size(tfd,1);
sc2 = size(tfd,2);
peaks = zeros(sc1,sc2);

mag_thresh = mean(tfd(:))*thresh; %%%%%%%%%%%%%

for i = 1:sc2
    time = tfd(:,i);
    d_time = diff(time);
    
    vect1 = [];
    for j = 2:length(d_time)
        if sign(d_time(j)) < 0 && sign(d_time(j-1)) > 0
            vect1 = [vect1,j];
        end
    end
    
    % searching for erroneous multipeaks
    if numel(vect1) ~= 0
        vect2 = [vect1(1)];
        close_neigh = 2; % close neighbour distance, can be varied to suit signal length
        for k = 2:length(vect1)
            if vect1(k) >= vect1(k-1) + close_neigh
                vect2 = [vect2,vect1(k)]; % otherwise forget the second point
            end
        end
    else
        vect2 = vect1;
    end
    
    for l = 1:length(vect2)
        if tfd(vect2(l),i) > mag_thresh
            peaks(vect2(l),i) = 1;
        end
    end
    
    
    
    clear vect1 vect2
end

