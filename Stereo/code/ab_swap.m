function [ labels, energy ] = ab_swap( init_labels, data_term, potts_cost, MAXD)
%AB_SWAP a-b swap algorithm for stereo matching, as described in Boykov,
%Veksler and Zabih, "Fast Approximate Energy Minimization via Graph Cuts",
%PAMI 2001.
%
%   Inputs:
%       init_labels: A h x w matrix containing the initial disparity
%           labels for every pixel.
%       data_term: A h x w x D matrix containing the data term cost for every
%           pixel and disparity. Computed by unary_cost.m.
%       potts_cost: A h x w x 4 matrix containing the smoothness cost for
%           every pixel. Doesn't depend on the pixel label. Potts (step) cost used.
%       MAXD: A scalar denoting the maximum disparity value we allow.
%
%   Outputs:
%       labels: The disparity map for the image at the local optimum found.
%       energy: The energy value computed by the maxflow algorithm.
disparities=0:MAXD;
pairs=generate_unique_pairs(disparities);
success = true;
E = edges4connected(size(init_labels, 1), size(init_labels, 2));
energy = compute_data_energy(init_labels, data_term);
edge_costs = compute_edge_costs(E, potts_cost, init_labels);
energy = energy + sum(edge_costs);
%fprintf('Initial Energy: %d\n', energy);
labels = init_labels;
cycle_count = 1;
while success == true
    fprintf('\tCycle %d running.\n', cycle_count);
    success=false;
    for p = 1:size(pairs, 1);
        a=pairs(p,1); b=pairs(p,2);
        %fprintf('\t\tIteration over disparities %d and %d running.\n', a, b);
        % Find the indices of the pixels that have labels a or b...
        inda = find(labels==a); indb=find(labels==b);
        %if(isempty(inda) || isempty(indb))
        %    continue; % TODO: Is this necessarily correct?
        %end
        %fprintf('Before constructing our matrices and running maxflow, we have %d pixels labeled with a and %d pixels labeled with b.\n', length(inda), length(indb));
        V = length(inda) + length(indb);
        % We need to generate a sparse V x 2 matrix T containing the costs
        % for associating every pixel with either the a or b label.
        T = create_data_term(V, data_term(:, :, a), data_term(:, :, b), inda, indb, E, edge_costs);
        
        % We need to construct the smoothness term. We will
        % use the provided edge map E. We note that, by construction of
        % T, its first |inda| rows correspond to the pixels in inda, and
        % its subsequent rows correspond to the pixels in indb. This
        % will help us make a transformation between the original edges
        % in the labeling and those that correspond to the graph Gab.
        A = create_smoothness_term(E, labels, a, b, inda, indb, edge_costs, V); 
        
        % Now we will run maxflow and update the labels if we improve.
        [~, lab_Gab] = maxflow(A, T); % TODO: Find why you have the same #nodes assigned to both a and b.
        %fprintf('flow computed:%d\n', flow);
        % Change the labels so that 0 means a and 1 means b:
        lab_Gab(lab_Gab == 0)=b; lab_Gab(lab_Gab == 1) = a;
        temp_labels = labels;
        temp_labels(inda) = lab_Gab(1:length(inda)); % Leveraging construction of T
        temp_labels(indb) = lab_Gab(length(inda)+1:end);
        % Compute the energy of temp_labels to see whether we improved...
        energy_templabs=compute_data_energy(temp_labels, data_term);
        % We have new labels, so we need updated edge costs. TODO: Check if
        % we should update the edge costs only if the energy is improved
        % upon.
        energy_templabs = energy_templabs + sum(edge_costs); 
        %fprintf('energy now:%d\n', energy_templabs);
        if(energy_templabs < energy)
            edge_costs = compute_edge_costs(E, potts_cost, temp_labels); 
            %fprintf('Energy reduced to: %d.\n', energy_templabs);
            energy = energy_templabs;
            labels = temp_labels;
            success=true;
        end 
    end % for pairs...
    cycle_count = cycle_count+1;
end % while success...
end


%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pairs = generate_unique_pairs(disparities)
% GENERATE_UNIQUE_PAIRS Given a list of disparities (essentially integers
%   from 1 to MAXD), generate all unique pairs of disparities.
%
%   Inputs:
%       disparities: A vector of disparities, containing the range of
%           disparities to be considered.
%   Outputs:
%       pairs: An (n choose 2) x 2 array containing all unique pairs of
%       disparities.
%
%   Notes:
%       This code was adapted from http://stackoverflow.com/questions/19037646/how-to-
%           generate-unique-pairs-of-the-elements-of-a-vector-ignoring-the-order-of
n = length(disparities);
assert(n > 0, 'No disparity range given');
[p, q] = meshgrid(1:n, 1:n);
mask = triu(ones(n), 1) > 0.5;
pairs = [q(mask) p(mask)]; % Changed the order of this
end

function E = compute_data_energy(labeling, data_term)
% COMPUTE_DATA_ENERGY Compute the total energy corresponding to the data
% term of the provided labeling.
%
%   Inputs:
%       labeling: An h x w matrix with every pixel labeled with its
%           disparity.
%       data_term: An h x w x MAXD matrix D(i, j, k) expresses the cost of
%           matching pixel L(i, j) with pixel R(i, j-k).
%   Outputs:
%       E: The computed data term energy.

% (1) Make a mapping between the matrix "labeling" and the linear indices
% of the 3D  matrix "smoothness_term".
h = size(labeling, 1); w = size(labeling, 2);
J = repmat(1:w, h, 1);
I = repmat((1:h)', 1, w);
IND = w*h*(labeling - 1) + h*(J-1) + I;

% (2) Sum the mapped values to find the total energy.
V=data_term(IND(:));
E = sum(V);
end

function s = compute_edge_costs(edge_map, potts_cost, labels)
% COMPUTE_EDGE_COSTS Compute the potts cost for every edge of the graph.
%
%   Inputs:
%       edge_map: An E x 2 vector representing the E different edges of the
%           grid graph. E(i, 1) ---> E(i, 2) is the representation of the
%           i-th edge, by virtue of denoting the vertices it connects.
%           Generated by edges4connected; see that method's
%           documentation for more information.
%       potts_cost: An h x w x 4 matrix containing the smoothness (potts)
%           cost for every pixel. Generated by potts_cost.m. See that method's
%           documentation for more information.
%   Outputs:
%       s: An E x 1 vector containing the potts cost for every edge.

s = zeros(size(edge_map, 1), 1);
% (1) Chop the edge map into 4 parts, to do appropriate indexing into
% potts_cost and populate s.
first_pixel_beginning_of_edge = find(edge_map(:, 1) == 1); % Should be a 2 x 1 vector. Asserted below.
first_pixel_end_of_edge = find(edge_map(:, 2) == 1); % Should also be a 2 x 1 vector. Also asserted below.
assert(length(first_pixel_beginning_of_edge) == 2, 'Should find two traces of the first pixel being the beginning of an edge.');
assert(length(first_pixel_end_of_edge) == 2, 'Should find two traces of the first pixel being the end of an edge.');

bottom_edges = edge_map(1:first_pixel_end_of_edge(1) - 1, :);
top_edges = edge_map(first_pixel_end_of_edge(1):first_pixel_beginning_of_edge(2) - 1, :);
right_edges = edge_map(first_pixel_beginning_of_edge(2):first_pixel_end_of_edge(2) - 1, :);
left_edges = edge_map(first_pixel_end_of_edge(2):end, :);
% Further sanity checking:
assert(length(bottom_edges) + length(top_edges) + length(right_edges) + length(left_edges) == length(s), 'Size mismatch.');

% (2)Take care of all different parts of s sequentially. Terrible code, but
% works (tested).
flattened = potts_cost(:, :, 1); flattened = flattened(:);
s(1:length(bottom_edges)) = flattened(bottom_edges(:, 1)); % Taking advantage of linear indexing
flattened = potts_cost(:, :, 2); flattened = flattened(:);
s(length(bottom_edges)+1:length(bottom_edges)+length(top_edges)) = flattened(top_edges(:, 1));
flattened = potts_cost(:, :, 3); flattened = flattened(:);
s(length([bottom_edges;top_edges])+1:length([bottom_edges;top_edges])+length(right_edges)) = flattened(right_edges(:, 1));
flattened = potts_cost(:, :, 4); flattened = flattened(:);
s(length([bottom_edges;top_edges;right_edges])+1:end) = flattened(left_edges(:, 1));

% Finally, we need to set zeros for all the costs where the assigned
% disparities are the same. This completes the full Potts cost formulation.
s(labels(edge_map(:, 1)) == labels(edge_map(:, 2))) = 0;
end

function T=create_data_term(V, unary_costs_a, unary_costs_b, inda, indb, E, edge_costs)
% CREATE_DATA_TERM Create the sparse data term matrix T to feed to maxflow.
%
%   Inputs:
%       V: The number of nodes in the graph.
%       unary_costs_a: A h*w matrix containing the unary costs of assigning every
%           pixel in the graph a label of a.
%       unary_costs_b: A h*w matrix containing the unary costs of assigning every
%           pixel in the graph a label of b.
%       inda: A vector that contains linear indices into the original
%           image. inda(i) contains the linear index of the i-th pixel that
%           had label a.
%      indb: A vector that contains linear indices into the original
%          image. indb(i) contains the linear index of the i-th pixel that
%          had label b.
%   Outputs:
%       T: A sparse V x 2 matrix. V(i,1) contains the unary cost of
%       assigning pixel i the label of a, whereas V(i, 2) contains the
%       unarty cost of assigning it label b.


% The following code creates T as sparse from scratch. We have also tested
% the code by creating T as a full matrix and then "sparsifying" it: the
% results are pretty much the same.
i = zeros(2*V, 1); j = i; s = j;
i(1:2:end) = 1:V; i(2:2:end) = i(1:2:end); % Set up T's row indices
j(1:2:end) = 1; j(2:2:end) = 2; % T's column indices

% We need to expand the costs for every pixel in Gab such that we include
% the smoothness costs of the edges towards neighbor pixels that have
% labels neither a nor b.

% Get the indices of the edges that involve a pixel in Gab and a pixel not
% in Gab.
[locs, vals] = ismember(E, [inda; indb]);
inds = logical(any(locs, 2) - all(locs, 2)); % puts '1's in the rows corresponding to edges that had exactly one pixel in Gab.
% Associate every one of the remainder edges by its vertex in Gab
% and sum up the relevant costs via accumarray.
vals = vals(inds, :);
assert(nnz(vals) == size(vals, 1) .* size(vals, 2) ./ 2, 'Exactly half of the elements of vals should be 0.');
GabPixels = vals(:, 1) + vals(:, 2); % What easiest way to make it into a vector of its nonzeros...
costsOfThoseEdges = edge_costs(inds);
assert(length(costsOfThoseEdges) == length(GabPixels), 'Size mismatch');
costs_a = [unary_costs_a([inda;indb]) ; costsOfThoseEdges];
costs_b = [unary_costs_b([inda;indb]) ; costsOfThoseEdges];
cost_sum_a = accumarray([[inda;indb] ; GabPixels], costs_a, [], @sum);
cost_sum_b = accumarray([[inda;indb] ; GabPixels], costs_b, [], @sum);
% Attention: accumarray creates many zeroes...
cost_sum_a = cost_sum_a([inda;indb]);
cost_sum_b = cost_sum_b([inda;indb]);
assert(length(cost_sum_a) == V, 'Length of cost sum for a should be V.');
assert(length(cost_sum_b) == V, 'Length of cost sum for b should be V.');
s(1:2:end) = cost_sum_a; s(2:2:end) = cost_sum_b;
T = sparse(i, j, s, V, 2);
end

function A=create_smoothness_term(E, labels, a, b, inda, indb, edge_costs, V)
% CREATE_SMOOTHNESS_TERM Create the sparse matrix A to feed to maxflow.
%   Inputs:
%       E: An E x 2 matrix representing the edge map. E(i, 1) and E(i, 2)
%           are the vertices connected by the i-th edge. Generated by
%           edges4connected; look up that particular method's documentation
%           for more.
%       labels: a h * w matrix representing the labels (disparities)of every pixel.
%       a, b: integer scalars representing the two different labels
%           (disparities) considered in the current iteration of a-b swap.
%       inda, indb: Vectors containing linear indices into the matrix
%           "labels". inda/b(i) contains the i-th pixel labeled a/b.
%       edge_costs: An E x 1 vector containing the cost of every edge.
%           Computed by local method "compute_edge_costs". Refer to that
%           method's comments for more information.
%       V: The number of nodes in the graph to run maxflow over.
%
%   Outputs:
%       A: A V X V sparse matrix containing the smoothness term for
%           maxflow. A(i, j) is the cost of the edge connecting pixel i to
%           pixel j. Since A is sparse, it will not contain any cells for
%           pixels that are not connected.

edgeselect = (labels(E(:, 1)) == a | labels(E(:, 1)) == b) & (labels(E(:, 2)) == a | labels(E(:, 2)) == b);
Eab=E(edgeselect, :); % Selecting only the appropriate edges
[~, Eab] = ismember(Eab, [inda;indb]); %!!! Beautiful
assert(all(Eab(:)), 'There should be no zeroes in Eab.');
s = edge_costs(edgeselect);
A = sparse(Eab(:, 1), Eab(:, 2), s, V, V);
end