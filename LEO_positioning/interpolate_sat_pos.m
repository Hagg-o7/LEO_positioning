function sat_pos = interpolate_sat_pos(eph, target_sow, sys)
    % Constants
    mu_GPS = 3.986005e14; % Earth's gravitational constant for GPS
    mu_GLONASS = 3.986004418e14; % Earth's gravitational constant for GLONASS
    OmegaE_dot = 7.2921151467e-5; % Earth's rotation rate

    % Select the appropriate gravitational constant
    if sys == 'G'
        mu = mu_GPS;
    elseif sys == 'R'
        mu = mu_GLONASS;
    else
        error('Unknown satellite system.');
    end

    % Find the nearest ephemeris entry
    [~, idx] = min(abs([eph.sow] - target_sow));
    eph_entry = eph(idx);
    
    % % Debug: Verify the structure of eph_entry
    % disp('Ephemeris entry:');
    % disp(eph_entry);
    % disp('Ephemeris data field:');
    % disp(eph_entry.data);

    % Extract ephemeris parameters
    prn = eph_entry.prn;
    t0e = eph_entry.sow;
    t = target_sow - t0e;
    
    a = eph_entry.data(9)^2; % Semi-major axis
    ecc = eph_entry.data(2); % Eccentricity
    i = eph_entry.data(10); % Inclination
    Omega0 = eph_entry.data(8); % Right ascension of ascending node
    w = eph_entry.data(6); % Argument of perigee
    M0 = eph_entry.data(3); % Mean anomaly at reference epoch
    Delta_n = eph_entry.data(5); % Mean motion difference

    % Corrected mean motion
    n0 = sqrt(mu / a^3);
    n = n0 + Delta_n;

    % Mean anomaly at epoch t
    M = M0 + n * t;

    % Solve Kepler's equation for E (Eccentric anomaly)
    E = M;
    for j = 1:10
        E = M + ecc * sin(E);
    end

    % True anomaly
    v = 2 * atan(sqrt((1 + ecc) / (1 - ecc)) * tan(E / 2));

    % Argument of latitude
    u = v + w;

    % Radial distance
    r = a * (1 - ecc * cos(E));

    % Positions in orbital plane
    x_orb = r * cos(u);
    y_orb = r * sin(u);

    % Correcting for Earth's rotation
    Omega = Omega0 + (OmegaE_dot - eph_entry.data(4)) * t;

    % ECEF coordinates
    x = x_orb * cos(Omega) - y_orb * cos(i) * sin(Omega);
    y = x_orb * sin(Omega) + y_orb * cos(i) * cos(Omega);
    z = y_orb * sin(i);

    sat_pos = [x, y, z];
end
