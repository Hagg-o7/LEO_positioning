% Load the ephemeris data
eph = read_eph('filtered_2024196.rnx');

% Verify the structure of eph
disp('Ephemeris structure:');
disp(eph);

% Continue with the rest of the code
% Define the observation period in SOW (example: 1 hour)
start_sow = 0;
end_sow = start_sow + 7200; % 2 hours

% Initialize the matrix to store interpolated ephemerides
interpolated_ephemerides = [];

% Loop through each 1-second epoch
h = waitbar(0, 'Please wait...');  % Create waitbar
for t = start_sow:end_sow
    for i = 1:length(eph)
        sys = eph(i).sys;
        sat_pos = interpolate_sat_pos(eph, t, sys);
        interpolated_ephemerides = [interpolated_ephemerides; t, eph(i).prn, sys, sat_pos];
    end
    waitbar(t / 7200, h, sprintf('Progress: %d %% (%d / 7200)', floor((t / 7200) * 100), t));
end
close(h)

% Save the interpolated ephemerides to a .dat file
save('interpolated_ephemerides.dat', 'interpolated_ephemerides', '-ascii');

disp('Interpolated ephemerides have been saved to interpolated_ephemerides.dat');
