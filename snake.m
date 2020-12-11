function snake(varargin)
%{
TODO:
remember fast pressing for next direction change
add obstacles
order colisiion detector
fix bug where cant restrat if pressing arrows after losing 
difficulty slider
%}

p = inputParser;
addParameter(p,'Size',15)
addParameter(p,'Warp',false)
addParameter(p,'Speed',2,@(x) x==1 || x==2 || x==3)

parse(p,varargin{:});



bsize = p.Results.Size;
warp = p.Results.Warp;
difficulty = p.Results.Speed;


BOXSIZE = [1 1];
START_POS = floor(bsize/2) * [1 1];
RIGHT = [1 0 0 0];
UP = [0 1 0 0];
LEFT = [-1 0 0 0];
DOWN = [0 -1  0 0];
SPEEDS = [0.12 0.08 0.05];

figure('KeyPressFcn',@Key_Down);
axis equal;
axis([0 bsize 0 bsize]);
xlim([0 bsize]);
ylim([0 bsize]);
xticks([]);
yticks([]);
xlabel('use arrow keys');
box;

head_pos = [START_POS BOXSIZE];
change_dir = true;
cur_dir = 0;
rects = [];

food_pos = [0 0];
food = rectangle('Position',[food_pos BOXSIZE]);
food.FaceColor='r';

points = 0;

t = timer;
t.ExecutionMode = 'fixedRate';
t.TimerFcn = @pass_time;
t.Period = SPEEDS(difficulty);

restart;

    function Key_Down(hObject, ~, ~)
        key = get(hObject,'CurrentKey');
        if strcmp(key, 'space')
            stop(t);
            restart;
        end
        if change_dir
            switch key
                case 'rightarrow'
                    if ~isequal(cur_dir, LEFT) && ~isequal(cur_dir, RIGHT)
                        cur_dir = RIGHT;
                        change_dir = false;
                    end
                case 'uparrow'
                    if ~isequal(cur_dir, DOWN) && ~isequal(cur_dir, UP)
                        cur_dir = UP;
                        change_dir = false;
                    end
                case 'leftarrow'
                    if ~isequal(cur_dir, LEFT) && ~isequal(cur_dir, RIGHT)
                        cur_dir = LEFT;
                        change_dir = false;
                    end
                case 'downarrow'
                    if ~isequal(cur_dir, DOWN) && ~isequal(cur_dir, UP)
                        cur_dir = DOWN;
                        change_dir = false;
                    end
            end
        end
    end

    function pass_time(~, ~, ~)
        move_objects;
        change_dir = true;
        if ~is_in_bounds(rects(1)) || self_collision
            stop(t);
            xlabel({'use arrow keys' ; 'Game over. Press space to restart.'});
        end
        if check_collision(food_pos, rects(1))
            new_r = rectangle('Position',[food_pos BOXSIZE],'FaceColor','g','EdgeColor','g');
            rects = [rects new_r];
            place_food;
            points = points + 10;
            title(['Points: ' num2str(points)]);
        end
        axis([0 bsize 0 bsize]);
    end

    function move_objects
        rects(1).EdgeColor = 'g';
        rects = circshift(rects,1);
        head_pos = mod(head_pos + cur_dir, bsize * warp);
        rects(1).Position = head_pos;
        rects(1).EdgeColor = 'k';
    end

    function place_food
        food_pos = randi(bsize-1, [1 2]);
        while check_collision(food_pos, rects)
            food_pos = randi(bsize-1, [1 2]);
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
        bound = x>=0 && y>=0 && x<bsize && y<bsize;
    end

    function col_det = self_collision
        col_det = false;
        if length(rects) > 1
            col_det = check_collision(rects(1).Position(1:2), rects(2:end));
        end
    end

    function restart
        head_pos = [START_POS BOXSIZE];
        cur_dir = 0;
        delete(rects);
        rects = rectangle('Position',head_pos,'FaceColor','g','EdgeColor','k');
        
        place_food;
        
        points = 0;
        title(['Points: ' num2str(points)]);
        xlabel('use arrow keys');
        start(t);
    end

end