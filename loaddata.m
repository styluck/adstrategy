function [p, w, groups, list_name] = loaddata(exclusions)
    
if nargin == 0 || isempty(exclusions) 
    exclusions = [];
end

    Dir_head = 'data/';
    list_name = {};
    files = dir(Dir_head);
    for i = 1:length(files)
        [~, fileName, ext] = fileparts(files(i).name);
        if strcmp(ext, '.mat')
            list_name{end+1} = fileName;
        end
    end
    
    le = length(exclusions);
    idx1 = [];
    if le > 1
        for i = 1:le
            [truefalse, idx] = ismember(exclusions{i}, list_name);
            if truefalse
                idx1 = [idx1,idx];
            end
        end
    end

    list_name(idx1) = [];

    % list_name = list_name(randperm(length(list_name)));
    n = length(list_name);
    
    p = [];
    w = [];
    groups = [];
    
    for i = 1:n
        data = load(fullfile(Dir_head, [list_name{i}, '.mat']));
        
        data.table = flip(cumsum(data.table), 1); % Flip and cumulative sum
        p_sub = data.table(:, 1); % values
        w_sub = data.table(:, 2); % weights
        
        n_sub = size(data.table, 1);
        g_sub = ones(n_sub, 1) * i; % groups
        
        p = [p; p_sub];
        w = [w; w_sub];
        groups = [groups; g_sub];
    end
end
