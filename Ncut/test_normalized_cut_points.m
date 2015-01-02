%%% This is the script provided for us. I made minor modifications to
%%% plot() to make the plots easier to read. 
function test_normalized_cut_points()
p1 = 2.5*rand(2,20);
p2 = 2.5*rand(2,20) + repmat([3;2], 1, 20);
p = [p1, p2];
q = normalized_cut_cont_points(p, 2.5);
msize = 10+20*(q-min(q))/(max(q)-min(q));
figure;
hold on;
for i = 1:size(p,2)
    plot(p(1,i), p(2,i), '.b', 'MarkerSize', msize(i)); % Had to modify the call to plot to make only blue markers.
end
figure;
hold on
group = normalized_cut_points(p, 2.5);
plot(p(1,group), p(2,group), '.r', 'MarkerSize', 10); % notice the indexing of p.
plot(p(1,~group), p(2, ~group), '.b', 'MarkerSize', 10);
