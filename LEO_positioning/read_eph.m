function eph = read_eph(filename)
    fid = fopen(filename, 'rt');
    if fid == -1
        error('Could not open the file.');
    end
    
    % Skip the header
    while true
        line = fgetl(fid);
        if contains(line, 'END OF HEADER')
            break;
        end
    end

    % Read ephemerides
    eph = [];
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line) || ~ismember(line(1), {'G', 'R'})
            continue;
        end

        prn = str2double(line(2:3));
        sys = line(1);
        epoch = sscanf(line(5:22), '%f %f %f %f %f %f')';
        
        % Convert raw time to SOW
        year = epoch(1);
        month = epoch(2);
        day = epoch(3);
        hour = epoch(4);
        minute = epoch(5);
        second = epoch(6);
        dt = datetime(year, month, day, hour, minute, second);
        week_num = gps_week(dt);
        sow = seconds(dt - gps_start_date(week_num));

        data = sscanf(line(23:end), '%f')';
        
        eph_entry = struct();
        eph_entry.prn = prn;
        eph_entry.sys = sys;
        eph_entry.sow = sow;
        eph_entry.data = data;
        
        % Read next lines of the same ephemeris record
        for i = 1:7
            line = fgetl(fid);
            data = sscanf(line, '%f')';
            eph_entry.data = [eph_entry.data, data];
        end
        
        eph = [eph; eph_entry];
    end
    
    fclose(fid);
end

function week_num = gps_week(dt)
    gps_start = datetime(1980, 1, 6);
    week_num = floor(days(dt - gps_start) / 7);
end

function start_date = gps_start_date(week_num)
    gps_start = datetime(1980, 1, 6);
    start_date = gps_start + days(week_num * 7);
end
