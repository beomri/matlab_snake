function snake
%{
TODO:
disable changing direction before moving
add obstacles
change fps to interval
add difficulty
add wrapping
%}
RANGE = 15;
BOXSIZE = [1 1];
START_POS = floor(RANGE/2) * [1 1];
FPS = 12.5;
RIGHT = [1 0 0 0];
UP = [0 1 0 0];
LEFT = [-1 0 0 0];
DOWN = [0 -1  0 0];

figure('KeyPressFcn',@Key_Down);
axis equal;
axis([0 RANGE 0 RANGE]);
xlim([0 RANGE]);
ylim([0 RANGE]);
xticks([]);
yticks([]);
xlabel('use arrow keys');

head_pos = [START_POS BOXSIZE];
cur_dir = 0;
rects = rectangle('Position',head_pos,'FaceColor','g','EdgeColor','k');

food_pos = [0 0];
food = rectangle('Position',[food_pos BOXSIZE]);
food.FaceColor='r';
place_food;

points = 0;
title(['Points: ' num2str(points)]);

t = timer;
t.ExecutionMode = 'fixedRate';
t.TimerFcn = @pass_time;
t.Period = 1/FPS;
start(t);

    function Key_Down(hObject, ~, ~)
        key = get(hObject,'CurrentKey');
        switch key
            case 'rightarrow'
                if ~isequal(cur_dir, LEFT)
                    cur_dir = RIGHT;
                end
            case 'uparrow'
                if ~isequal(cur_dir, DOWN)
                    cur_dir = UP;
                end
            case 'leftarrow'
                if ~isequal(cur_dir, RIGHT)
                    cur_dir = LEFT;
                end
            case 'downarrow'
                if ~isequal(cur_dir, UP)
                    cur_dir = DOWN;
                end
        end
    end

    function pass_time(~, ~, ~)
        move_objects;
        if ~is_in_bounds(rects(1)) || self_collision
            stop(t);
        end
        if check_collision(food_pos, rects(1))
            new_r = rectangle('Position',[food_pos BOXSIZE],'FaceColor','g','EdgeColor','g');
            rects = [rects new_r];
            place_food;
            points = points+10;
            title(['Points: ' num2str(points)]);
        end
        axis([0 RANGE 0 RANGE]);
    end

    function move_objects
        rects(1).EdgeColor = 'g';
        rects = circshift(rects,1);
        head_pos = head_pos + cur_dir;
        rects(1).Position = head_pos;
        rects(1).EdgeColor = 'k';
    end

    function place_food
        food_pos = randi(RANGE-1, [1 2]);
        while check_collision(food_pos, rects)
            food_pos = randi(RANGE-1, [1 2]);
        end
        food.Position = [food_pos BOXSIZE];
    end

    function col_det = check_collision(pos, rects2check)
        for r=rects2check
            if isequal(pos, r.Position(1:2))
                col_det = true;
                return;
            end
        end
        col_det = false;
    end

    function bound = is_in_bounds(r)
        pos = r.Position;
        x = pos(1);
        y = pos(2);
        bound = x>=0 && y>=0 && x<RANGE && y<RANGE;
    end

    function col_det = self_collision
        col_det = false;
        if length(rects) > 1
            col_det = check_collision(rects(1).Position(1:2), rects(2:end));
        end
    end

end