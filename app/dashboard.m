function dashboard
    % Create main UI
    fig = uifigure('Name', 'Data Analysis Dashboard', 'Position', [100 100 800 500]);

    % UI components
    btnLoad = uibutton(fig, 'Text', 'Load CSV', 'Position', [30 450 100 30], ...
        'ButtonPushedFcn', @(btn,event) loadData());

    lblX = uilabel(fig, 'Text', 'X Variable:', 'Position', [160 455 70 20]);
    dropdownX = uidropdown(fig, 'Position', [230 450 120 30]);

    lblY = uilabel(fig, 'Text', 'Y Variable:', 'Position', [370 455 70 20]);
    dropdownY = uidropdown(fig, 'Position', [440 450 120 30]);

    ax = uiaxes(fig, 'Position', [30 100 500 330]);
    ax.XGrid = 'on'; ax.YGrid = 'on';

    txtStats = uitextarea(fig, 'Position', [550 100 220 280], 'Editable', 'off');
    txtStats.FontSize = 12;
    
    btnScatter = uibutton(fig, 'Text', 'Scatter Plot', 'Position', [580 400 150 30], ...
        'ButtonPushedFcn', @(btn,event) plotScatter());
    btnHist = uibutton(fig, 'Text', 'Histogram (X)', 'Position', [580 360 150 30], ...
        'ButtonPushedFcn', @(btn,event) plotHistogram());
    btnBox = uibutton(fig, 'Text', 'Boxplot (X)', 'Position', [580 320 150 30], ...
        'ButtonPushedFcn', @(btn,event) plotBox());

    data = [];

    % --- Functions ---
    function loadData()
        [file, path] = uigetfile('*.csv');
        if isequal(file, 0)
            return;
        end
        fullPath = fullfile(path, file);
        data = readtable(fullPath);
        vars = data.Properties.VariableNames;
        dropdownX.Items = vars;
        dropdownY.Items = vars;
        txtStats.Value = {'CSV Loaded! Select variables to begin.'};
    end

    function plotScatter()
        if isempty(data), return; end
        x = dropdownX.Value;
        y = dropdownY.Value;
        scatter(ax, data.(x), data.(y), 'filled');
        title(ax, sprintf('Scatter Plot: %s vs %s', y, x));
        xlabel(ax, x); ylabel(ax, y);
        updateStats(x);
    end

    function plotHistogram()
        if isempty(data), return; end
        x = dropdownX.Value;
        histogram(ax, data.(x));
        title(ax, sprintf('Histogram of %s', x));
        xlabel(ax, x); ylabel(ax, 'Frequency');
        updateStats(x);
    end

    function plotBox()
        if isempty(data), return; end
        x = dropdownX.Value;
        boxplot(ax, data.(x));
        title(ax, sprintf('Boxplot of %s', x));
        xlabel(ax, x);
        updateStats(x);
    end

    function updateStats(varName)
        vals = data.(varName);
        stats = {
            sprintf('Variable: %s', varName)
            sprintf('Mean: %.2f', mean(vals, 'omitnan'))
            sprintf('Median: %.2f', median(vals, 'omitnan'))
            sprintf('Std Dev: %.2f', std(vals, 'omitnan'))
            sprintf('Missing: %d', sum(ismissing(vals)))
            };
        txtStats.Value = stats;
    end
end
