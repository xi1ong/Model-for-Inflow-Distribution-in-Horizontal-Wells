function build_conceptual_model()
%BUILD_CONCEPTUAL_MODEL Generate panel c and assemble the conceptual figure.
% Requires MATLAB graphics, Microsoft PowerPoint automation, and pdfcrop.

% Resolve source and output locations relative to this function.
root_dir = fileparts(fileparts(mfilename('fullpath')));
fig_dir = fullfile(root_dir, 'figures');
source_pptx = fullfile(root_dir, 'conceptual_model.pptx');

if ~isfile(source_pptx)
    error('Source presentation not found: %s', source_pptx);
end
if ~isfolder(fig_dir)
    mkdir(fig_dir);
end

panel_pdf = fullfile(fig_dir, 'fig0c_boundary_diameter.pdf');
panel_png = fullfile(fig_dir, 'fig0c_boundary_diameter.png');
panel_emf = fullfile(fig_dir, 'fig0c_boundary_diameter.emf');
output_pptx = fullfile(fig_dir, 'fig0_conceptual_model.pptx');
output_pdf = fullfile(fig_dir, 'fig0_conceptual_model.pdf');
output_png = fullfile(fig_dir, 'fig0_conceptual_model.png');

% Render the computed panel before inserting it into the editable slide.
draw_panel_c(panel_pdf, panel_png, panel_emf);
combine_with_powerpoint(source_pptx, panel_emf, output_pptx, output_pdf, output_png);

fprintf('Conceptual-model outputs:\n');
fprintf('  %s\n', output_pptx);
fprintf('  %s\n', output_pdf);
fprintf('  %s\n', output_png);
end

function draw_panel_c(pdf_path, png_path, emf_path)
%DRAW_PANEL_C Draw boundary-condition and diameter-profile schematics.
panel_width_cm = 15.30;
panel_height_cm = 3.90;

f = figure('Visible', 'off', ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [2, 2, panel_width_cm, panel_height_cm], ...
    'PaperPositionMode', 'auto');
cleanup_figure = onCleanup(@() close(f));

ax = axes(f, 'Position', [0, 0, 1, 1], ...
    'XLim', [0, 1], 'YLim', [0, 1], ...
    'Visible', 'off', 'Clipping', 'off');
hold(ax, 'on');

font_name = 'Times New Roman';
blue = [0.00, 0.45, 0.70];
orange = [0.85, 0.33, 0.10];
pipe_edge = [0.12, 0.32, 0.48];
pipe_fill = [0.82, 0.90, 0.95];
grey = [0.67, 0.67, 0.67];

text(ax, 0.010, 0.955, '(c)', ...
    'FontName', font_name, 'FontSize', 9, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

plot(ax, [0.425, 0.425], [0.08, 0.91], '-', ...
    'Color', [0.78, 0.78, 0.78], 'LineWidth', 0.6);

% Contrast the inflow and head constraints imposed by UFBC, UHBC, and MTBC.
centres = [0.078, 0.215, 0.352];
names = {'UFBC', 'UHBC', 'MTBC'};
constraints = {'q_j = Q/N_k', 'h_j = h_w', 'q_j \leftrightarrow h_j'};

for k = 1:3
    xc = centres(k);
    x_well = linspace(xc - 0.052, xc + 0.052, 80);
    y_well = 0.515;

    plot(ax, x_well, y_well * ones(size(x_well)), 'k-', 'LineWidth', 1.0);
    plot(ax, [x_well(1), x_well(1)], [y_well - 0.028, y_well + 0.028], ...
        'k-', 'LineWidth', 0.8);
    draw_arrow(ax, x_well(end) - 0.014, y_well, x_well(end) + 0.006, y_well, ...
        [0, 0, 0], 0.7, 0.007, 0.010);

    xq = linspace(xc - 0.041, xc + 0.041, 5);
    if k == 1
        y_start = 0.285 * ones(1, 5);
    elseif k == 2
        y_start = [0.255, 0.325, 0.275, 0.365, 0.305];
    else
        y_start = [0.340, 0.315, 0.285, 0.255, 0.230];
    end
    for j = 1:numel(xq)
        draw_arrow(ax, xq(j), y_start(j), xq(j), y_well - 0.022, ...
            blue, 0.8, 0.012, 0.008);
    end

    t = linspace(0, 1, numel(x_well));
    if k == 1
        head_profile = 0.755 + 0.055 * (t - 0.15).^2;
    elseif k == 2
        head_profile = 0.780 * ones(size(t));
    else
        head_profile = 0.740 + 0.075 * t.^1.35;
    end
    plot(ax, x_well, head_profile, '-', 'Color', orange, 'LineWidth', 1.0);

    text(ax, xc, 0.155, names{k}, ...
        'FontName', font_name, 'FontSize', 8, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    text(ax, xc, 0.075, constraints{k}, ...
        'Interpreter', 'tex', 'FontName', font_name, 'FontSize', 7, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

text(ax, 0.447, 0.925, 'toe, x = 0', ...
    'FontName', font_name, 'FontSize', 7, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
draw_arrow(ax, 0.548, 0.855, 0.895, 0.855, [0, 0, 0], 0.7, 0.010, 0.010);
text(ax, 0.985, 0.925, 'heel / pump, x = L', ...
    'FontName', font_name, 'FontSize', 7, ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle');

% Draw constant and tapered diameter profiles on a common spatial scale.
profile_centres = [0.505, 0.640, 0.775, 0.915];
profile_names = {'Equal mean', 'Equal volume', 'Forward', 'Reverse'};
profile_values = {'D = 0.175 m', 'D = 0.1803 m', ...
    '0.10 \rightarrow 0.25 m', '0.25 \rightarrow 0.10 m'};
pipe_width = 0.105;
pipe_y = 0.535;
half_mean = 0.0400;
half_volume = half_mean * 0.180278 / 0.175;
half_toe = half_mean * 0.10 / 0.175;
half_heel = half_mean * 0.25 / 0.175;

for k = 1:4
    x1 = profile_centres(k) - pipe_width / 2;
    x2 = profile_centres(k) + pipe_width / 2;
    if k == 1
        h1 = half_mean;
        h2 = half_mean;
    elseif k == 2
        h1 = half_volume;
        h2 = half_volume;
    elseif k == 3
        h1 = half_toe;
        h2 = half_heel;
    else
        h1 = half_heel;
        h2 = half_toe;
    end

    draw_pipe(ax, x1, x2, pipe_y, h1, h2, pipe_fill, pipe_edge, grey);
    text(ax, profile_centres(k), 0.305, profile_names{k}, ...
        'FontName', font_name, 'FontSize', 8, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    text(ax, profile_centres(k), 0.205, profile_values{k}, ...
        'Interpreter', 'tex', 'FontName', font_name, 'FontSize', 7, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

% Export vector and raster variants for document and slide workflows.
exportgraphics(f, pdf_path, 'ContentType', 'vector', 'BackgroundColor', 'white');
exportgraphics(f, png_path, 'Resolution', 600, 'BackgroundColor', 'white');
print(f, emf_path, '-dmeta', '-r600');
clear cleanup_figure;
end

function draw_pipe(ax, x1, x2, yc, h1, h2, face_colour, edge_colour, centre_colour)
%DRAW_PIPE Render a constant or linearly tapered pipe polygon.
x = [x1, x2, x2, x1];
y = [yc + h1, yc + h2, yc - h2, yc - h1];
patch(ax, x, y, face_colour, ...
    'EdgeColor', edge_colour, 'LineWidth', 1.0);
plot(ax, [x1, x2], [yc, yc], '--', 'Color', centre_colour, 'LineWidth', 0.5);
plot(ax, [x1, x1], [yc - h1, yc + h1], '-', 'Color', edge_colour, 'LineWidth', 0.8);
plot(ax, [x2, x2], [yc - h2, yc + h2], '-', 'Color', edge_colour, 'LineWidth', 0.8);
end

function draw_arrow(ax, x1, y1, x2, y2, colour, line_width, head_length, head_width)
%DRAW_ARROW Draw a line and triangular arrowhead in axes coordinates.
dx = x2 - x1;
dy = y2 - y1;
arrow_length = hypot(dx, dy);
if arrow_length == 0
    return;
end
ux = dx / arrow_length;
uy = dy / arrow_length;
px = -uy;
py = ux;
base_x = x2 - head_length * ux;
base_y = y2 - head_length * uy;

plot(ax, [x1, base_x], [y1, base_y], '-', 'Color', colour, 'LineWidth', line_width);
patch(ax, [x2, base_x + 0.5 * head_width * px, base_x - 0.5 * head_width * px], ...
    [y2, base_y + 0.5 * head_width * py, base_y - 0.5 * head_width * py], ...
    colour, 'EdgeColor', colour, 'LineWidth', 0.5);
end

function combine_with_powerpoint(source_pptx, panel_emf, output_pptx, output_pdf, output_png)
%COMBINE_WITH_POWERPOINT Insert panel c and export the composed figure.
% Work on a copy so the source presentation remains unchanged.
copyfile(source_pptx, output_pptx, 'f');
output_dir = fileparts(output_pdf);
full_pdf = fullfile(output_dir, 'fig0_conceptual_model_full.pdf');
full_png = fullfile(output_dir, 'fig0_conceptual_model_full.png');
if isfile(output_pdf)
    delete(output_pdf);
end
if isfile(output_png)
    delete(output_png);
end
if isfile(full_pdf)
    delete(full_pdf);
end
if isfile(full_png)
    delete(full_png);
end

% Convert the slide frame and panel bounds from EMUs to PowerPoint points.
emu_per_point = 12700;
outer_left = 3306000 / emu_per_point;
outer_top = 1629000 / emu_per_point;
outer_width = 5580000 / emu_per_point;
outer_height = 3600000 / emu_per_point;
slide_width_emu = 12192000;
slide_height_emu = 6858000;
c_left = 3340800 / emu_per_point;
c_top = 3790800 / emu_per_point;
c_width = 5508000 / emu_per_point;
c_height = 1404000 / emu_per_point;
inset = 1.0;

% Automate PowerPoint with explicit cleanup on both success and failure.
ppt = [];
presentation = [];
try
    ppt = actxserver('PowerPoint.Application');
    presentation = ppt.Presentations.Open(output_pptx, 0, 0, 0);
    slide = presentation.Slides.Item(1);

    fix_source_panel_text(slide);

    slide.Shapes.AddPicture(panel_emf, 0, -1, ...
        c_left + inset, c_top + inset, c_width - 2 * inset, c_height - 2 * inset);

    presentation.Save;

    full_width_px = round(slide_width_emu / 914400 * 600);
    full_height_px = round(slide_height_emu / 914400 * 600);
    slide.Export(full_png, 'PNG', full_width_px, full_height_px);
    presentation.SaveAs(full_pdf, 32);

    presentation.Close;
    ppt.Quit;
    delete(ppt);
catch err
    try
        if ~isempty(presentation)
            presentation.Close;
        end
    catch
    end
    try
        if ~isempty(ppt)
            ppt.Quit;
            delete(ppt);
        end
    catch
    end
    rethrow(err);
end

% Crop the high-resolution slide raster to the editable outer frame.
full_image = imread(full_png);
x_offset = round(3306000 / slide_width_emu * full_width_px);
y_offset = round(1629000 / slide_height_emu * full_height_px);
crop_width = round(5580000 / slide_width_emu * full_width_px);
crop_height = round(3600000 / slide_height_emu * full_height_px);
cropped_image = full_image( ...
    y_offset + (1:crop_height), ...
    x_offset + (1:crop_width), :);
imwrite(cropped_image, output_png, 'png');

% Convert the same frame to a bottom-left PDF bounding box.
slide_height_pt = slide_height_emu / emu_per_point;
bbox_left = outer_left;
bbox_bottom = slide_height_pt - outer_top - outer_height;
bbox_right = outer_left + outer_width;
bbox_top = bbox_bottom + outer_height;

% Run pdfcrop from the package root so quoted relative paths remain stable.
root_dir = fileparts(output_dir);
old_dir = pwd;
cleanup_dir = onCleanup(@() cd(old_dir));
cd(root_dir);
crop_command = sprintf([ ...
    'pdfcrop --quiet --bbox "%.6f %.6f %.6f %.6f" ', ...
    '"figures/fig0_conceptual_model_full.pdf" ', ...
    '"figures/fig0_conceptual_model.pdf"'], ...
    bbox_left, bbox_bottom, bbox_right, bbox_top);
[crop_status, crop_message] = system(crop_command);
if crop_status ~= 0
    error('PDF crop failed: %s', crop_message);
end
clear cleanup_dir;
cd(old_dir);

delete(full_pdf);
delete(full_png);
end

function fix_source_panel_text(slide)
%FIX_SOURCE_PANEL_TEXT Normalize known labels in the original slide panels.
replacements = {
    'z lenth=c', 'z length=c';
    'y lenth=b', 'y length=b';
    'x lenth=a', 'x length=a';
    'Well Lenth=L', 'Well length=L';
    'hell', 'heel'};

for k = 1:slide.Shapes.Count
    fix_shape_text(slide.Shapes.Item(k), replacements);
end
end

function fix_shape_text(shape, replacements)
%FIX_SHAPE_TEXT Traverse grouped shapes and update any accessible text frame.
try
    % Recurse into grouped shapes because their child text frames are not top-level.
    if get(shape, 'Type') == 6
        group_items = get(shape, 'GroupItems');
        for k = 1:get(group_items, 'Count')
            fix_shape_text(group_items.Item(k), replacements);
        end
    end
catch
end

try
    % Ignore COM shapes that do not expose editable text.
    if get(shape, 'HasTextFrame') ~= 0
        text_frame = get(shape, 'TextFrame');
        text_range = get(text_frame, 'TextRange');
        original_text = char(get(text_range, 'Text'));
        if isempty(strtrim(original_text))
            return;
        end
        normalized_text = regexprep(original_text, '\s+', ' ');
        normalized_text = strtrim(normalized_text);

        if contains(normalized_text, 'Constant Head Boundary')
            revised_text = sprintf('Constant-head\rboundaries\rx = 0, x = a');
        else
            revised_text = original_text;
            for k = 1:size(replacements, 1)
                revised_text = strrep(revised_text, replacements{k, 1}, replacements{k, 2});
            end
        end

        if ~strcmp(revised_text, original_text)
            set(text_range, 'Text', revised_text);
            if contains(normalized_text, 'Constant Head Boundary')
                centre_x = get(shape, 'Left') + get(shape, 'Width') / 2 + 10;
                set(shape, 'Width', 75);
                set(shape, 'Left', centre_x - 37.5);
                set(shape, 'Top', get(shape, 'Top') + 12);
                set(text_frame, 'AutoSize', 0);
                set(text_frame, 'WordWrap', -1);
                text_range = get(text_frame, 'TextRange');
                text_font = get(text_range, 'Font');
                set(text_font, 'Name', 'Times New Roman');
                set(text_font, 'Size', 9);
                set(text_font, 'Bold', -1);
                paragraph_format = get(text_range, 'ParagraphFormat');
                set(paragraph_format, 'Alignment', 2);
            end
            fprintf('  Updated source-panel text: %s\n', normalized_text);
        end
    end
catch
end
end
