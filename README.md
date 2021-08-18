# Graph

A Swift package including graph definitions and implementation, adopting positive `Int` values as vertices, in a range starting from `0` up to the count of vertices a graph instance must hold.

## `Graph` Protocol
This protocol abstracts basic properties and functionalities for a concrete graph type with value semantics.
`Graph` protocol is generic over an associated `Edge` type, which in turns should conform to `GraphEdge` protocol. 

### `Graph` types differentation rationale
A weighted graph would use as its `Edge` associated type a concrete type conforming to `WeightedGraphEdge` protocol, which inherits from `GraphEdge` and defines the additional properties and functionalities for a weighted edge over a generic `Weight` type.

On the other hand, a concrete graph type which uses unweighted edges, will have as 
its `Edge` associated type a concrete type conforming just to the `GraphEdge` protocol.
`GraphEdge` and `WeightedGraphEdge` protocols don't differentiate explicitly between directed and undirected connections, therefore `Graph` protocol defines the getter `kind` which must return a `GraphConnections` value defining if a graph instance etiher has directed connections between its vertices —when such returned value is `.directed`—, or undirected connections —when such returned value is `.undirected`.

### `Graph` vertices
A concrete type conforming to `Graph` protocol must also implement the getter `vertexCount`, which returns an `Int` value that is the number of vertices the graph instance contains. 
A graph has its vertices defined in the range `0..<vertexCount`, therefore this getter must return a non negative `Int` value.

### `Graph` edges
Type conforming to `Graph` protocol must also define the getter `edgeCount`, which must return a non negative `Int` value representing the total number of edges present in the graph instance, in respect to the `kind` value of such instance. 
As mentioned before, since the direction of connections between vertices in a graph is defined by its `kind` getter, the number of edges present in a graph instance via the getter `edgeCount` must take into account such `kind` value. That is for an undirected graph, the value returned by `edgeCount` must count an adjacency between a vertex `v` and `w` as one undirected edge and not as two directed edges.
On the other hand, for directed graph instances, this value must count as two edges a strong connection between two vertices `v` and `w`: that is when `v` is adjacent to `w` and the other way around.

### Creating a graph
The `Graph` protocol defines the initializer `init(kind:edges:)` for creating new graph instances.
Conforming types must take into account the given `kind` value in regards on how to store the subsequent given array of edges that the new graph instance must hold, as well as dimension its `vertexCount` according to the vertices values those edges hold.
Once a graph instance is created, it must hold all the edges in the given array passed to the initializer, thus having its `edgeCount` equal to the `count` value of such array.
Duplicate edges in the array must be added as parallel edges to the graph instance; this also imply that when the given `kind` value is `.undirected`, the given `edges` array parameter should not hold two edges one as inversion of another one to specify a connection between two vertices, otherwise such edges should be treated as two parallel undirected edges. 

### Adjacencies 
`Graph` protocol requires conforming types to implement the method `adjacencies(vertex:)`, this method should return as an array of edges all the connections from the given `vertex` parameter to other vertices in a graph instance.
Edges returned by this method should be handled according to the `GraphEdge` protocol, thus obtaining the adjacent vertex via the `GraphEdge` method `other(vertex:)` by passing to it the same
`vertex` value passed originally to the graph method `adjacencies(vertex:)` to obtain such edges.
Note that this method should also return self loops in the array, if the given vertex has any set in the graph.

### Reversing a graph
`Graph` protocol defines also the method `reversed()`, which should return the *inversion* of a graph instance. 
When a graph instance has its `kind` value equal to `.directed`, then this method should return another graph instance with its `kind` value equal to `.directed`, but with the edges of the calee in inverted direction. On the other hand for graph instances with `kind` value equal to `.undirected`, this method might as well just return the same graph instance; that is inverting an undirected graph will produce the same graph.

### `Graph` equality and hashing
`Graph` protocol has its default implementation for equality comparison of two instances taking into account the order of edges in the arrays returned by the `adjacencies(vertex:)` method on every vertex; this very same beahvior is reflected by the default `Hashable` implementation.

## Traversing a `Graph`
`Graph` protocol defines some methods with default implementations for traversing a graph.
These methods have a *Functional Programming* approach, and take one or more non escaping closures that will be executed during the traversal of the graph, passing as parameters to them vertices and/or edges encountered during such traversal, and other data relevant to the traversal.
Some of these methods also give the opportunity to the caller to specify the traversal strategy to adopt,
by getting as parameter a `GraphTraversal` value.

### Visit every vertex of a graph
Both methods `visitEveryVertexAdjacency(adopting:_:)` and `visitAllVertices(adopting:_:)` will visit every vertex in the graph instance, **regardless if any of the vertex is disconnected in the graph**. 
These methods will start at vertex `0` of the graph, proceeding on the adjacencies by adopting the given traversal strategy, and then keep visiting those vertices not discovered by the adjacencies found, until every vertex in the graph has been visited.
Note that **adjacencies leading to vertices already being visited during the traversal are not enumerated**.
Therefore the method executing a closure receiving the visited vertex and an edge from its adjacencies as parameter will only execute such closure for adjacencies leading to vertices not yet visited, and **will not enumerate parallel edges or self-loop edges**. 

### Visited vertices starting from a source vertex
The three methods with signature `visitedVertices(adopting:reachableFrom:_:)` will proceed from the given `source` vertex following adjacencies adopting the specified traversal methodology, by executing the given body closure and finally returning a set containig all the vertices visited during the traversal. 
Thus these methods will stop after every vertex discoverable from the given source one has been visited in the graph. 
* The first one takes a body closure with the signature: `(Int, Edge) throws -> Void`.  That is the body closure will get as parameters the vertex actually being visited and an edge discovered that leads to an adjacent vertex not yet visited. Thus this method **will not enumerate edges representing a parallel connection, nor edges representing a self-loop**.
* The second one takes a body closure with the signature: `(Int) throws -> Void`. This body closure recevies as its parameter the vertex being visited during the traversal. **Note that it will execute only for vertices on their first discovery**.
* The third method takes a body closure with the signature: `(inout Bool, Int, Edge, Bool) throws -> Void`. The first parameter passed to such closure is a mutable boolean value which can be set to `true` in the body closure to make the traversal stop. The second parameter is the vertex being visited, the third is an edge leading to an adjacency of such vertex, and the fourth final parameter is a boolean value signaling if the edge leads to an adjacent vertex that was already discovered during the traversal or not. Thus **this method will effectively enumerate every edge of the visited vertices during the traversal, no matter if they represent a parallel connection or a self-loop**. Moreover **it also gives the opportunity to stop the traversal by setting the stop mutable parameter to true in the body closure**.

### Depth Frist Search and Breadth First Search traversal utilities
The method `depthFirstSearch(preOrderVertexVisit:visitingVertexAdjacency:postOrderVertexVisit:)` is a graph traversal utility specifically suited to use *Depth First Search* strategy when traversing every vertex of the graph. 
This utility will execute three given closures:
1) `preorderVertexVisit` is executed when a vertex is firstly visited by the traversal; such vertex passed as its parameter.
2) `visitingVertexAdjacency` is executed while the traversal enumerates through the adjacencies of the vertex being visited; such vertex is passed as its first parameter, the edge being enumerated is passed as its second parameter, a boolean value signaling wheter the adjacent vertex of the enumerated edge had been already visitied by the traversal. 
3) `postOrderVertexVisit` is executed as every adjacency of the visited vertex have been enumerated and traversed; such vertex is passed as its parameter.
Because this method uses a recursive depth first search strategy, every time a vertex not yet visited is discovered during the adjacencies enumeration of the vertex being visited a new traversal starts from such adjacency, and so on.


The method `breadthFirstSearch(preOrderVertexVisit:visitingVertexAdjacency:postOrderVertexVisit:)` shares the same closure parameters of `depthFirstSearch`, but it will use the *Breadth First Search* strategy to traverse every vertex of the graph. Therefore when a vertex is firstly visited all its adjacency edges are enumerated, and then it proceeds to visit the adjacencies leading to vertices not yet visited.

Note that both these methods will enumerate every edge in the graph, regardless if it leads to a vertex that has been already visited or not. This is a different behavior from the other traversal methods described in the previous sections, therefore parallel edges and self loop edges are enumerated with these traversal methods.

Moreover both methods will visit every vertex in the graph starting from `0`, proceding following adjacencies with the traversal strategy until possible, then repeat on next vertex not yet visited and so on until every vertex in the graph has been visited.

## `GraphConnections`
A swift enum used to differentiate connections in a graph between *directed* and *undirected*.

## `GraphTraversal`
A swift enum used to define graph adjacencies traversal methodologies, either *Depth First Search* or *Breadth First Search*.

## `MutableGraph` Protocol
This protocol inherits from `Graph` protocol and abstracts functionalities for conforming types to add and remove edges as well as to reverse in place the graph, adopting value semantics.

### Initializing a mutable graph
A mutable graph can be created either by using the `Graph` protocol initializer `init(kind:edges)` or by adopting the `init(kind:vertexCount:)`.
Conforming types must implement this initializer, which is supposed to initialize graph with no edges
and with the specified number of vertices.

### Adding edges 
Conforming types must implement the method `add(edge:)`, this method is used to add a new edge to the graph, and should take into account the `kind` value of the mutable graph instance, by treating accordingly the given edge. 
The `edgeCount` value must be updated accordingly on edge addition.
Moreover the given edge should not be out of the actual vertices bounds of the graph.

### Removing edges
Conforming types must also implement `remove(edge:)` and `removeAllEdges()` methods.

`remove(edge:)` method must return a boolean value, `true` when given edge was removed from the graph, otherwise `false`. This method should also take into account the `kind` value of the graph instance, by treating the given edge accordigly. For example when `kind` value is `.undirected` and the given edge represents an existing connection in the graph between vertex `v` and vertex `w`, the method should treat such vertex as an *undirected* edge. 
The `edgeCount` value must be updated accordingly on edge removal.
Moreover the given edge should not be out of the actual vertices bounds of the graph.

`removeAllEdges()` method should effectively remove every edge in the graph, so that after the mutation has occurred the `edgeCount` value of the graph must be equal to `0` and every vertex in the graph must not have any adjacency.

### In place reversing
Types conforming to `MutableGraph` protocol must also implement the `reverse()` mutating method, which reverses in place the graph intance, following the same principles of  `Graph` protocol method `reversed()`:

```Swift
// Supposing graph is a mutable graph, then:
let revGraph = graph.reversed()

graph.reverse()
// graph == revGraph MUST BE TRUE
```
## `GraphEdge` Protocol
This protocol abstracts basic properties and functionalities of a graph edge with value semantics.
A type conforming to `GraphEdge` must implement the `either` value getter, which must return a non negative `Int` value representing one of the graph vertices it connects.
To get the other connected vertex of an edge, the method `other(_:)` must be implemented.
Such method must be implemented according to the following rules, supposing `v` and `w` are the two vertices connected by the edge and `either == v`:
1) `other(v)` must return `w`.
2) `other(w)` must return `v`.
3) `other(u)` where `u != v` and `u != w` must not be allowed and should trigger a runtime error.

`GraphEdge` protocol is suited to treat a connection in a graph *directionless*. It is responsability of the graph implementation to treat such edge accordingly to ts connection type.

A conforming types must also implement the `reversed()` method, which must be implemented according to the following rules, supposing `e` is an edge instance, `e.either == v` and `e.other(v) == w`
1) `e.reversed().either` must return `w`
2) `e.reversed().other(w)` must return `v`
3) `e.reversed().other(v)` must return `w`

### Default implementations
`GraphEdge` protocol provides some default implementations helpers:
* `tail` getter will return the same value of `either`.
* `head` getter will return the same value of `other(either)`
* `isSelfLoop` getter will return a boolean value, `true` when `either == other(either)`, otherwise `false`.

**It is highly recommended to not override these helpers**.

### `GraphEdge` equality and hashing
`GraphEdge` has its default implementations for both, comparison for equality and hashing. 
Such default implementations leverages on `either` getter value and `other(either)` returned value.

### `GraphEdge` undirected comparison operator `<~>`
The `<~>` infix operator is implemented for `GraphEdge` to allow comparision between two edges as undirected. That is supposing `e` and `d` are two edges where `e.either == v`, `d.either == w` then:

```Swift
let areUndirectedEqual = e <~> d
// areUndirectedEqual == true when e.other(v) == w and d.other(w) == v

// More in general:
let f = e.reversed()

e <~> f
// RETURNS TRUE


// Moreover supposing e == g then:

e <~> g
// RETURNS TRUE
```
## `WeightedGraphEdge` Protocol
This protocol inherits from `GraphEdge` protocol, adding abstractions defining properties and functionality for *weighted* edges adopting value semantics. 
That is `WeightedGraphEdge` protocol associates to a generic `Weight` type which must conforms to `AdditiveArithmetic`, `Comparable` and `Hashable` protocols.
`Weight` associated type is used to represent the *weight* of an edge in a graph adopting as its `Edge` associated type some `WeightedGraphEdge` concrete type.
In this way `Graph` conforming types can be decoupled from specific implementations for weighted graphs.

Types conforming to `WeightedGraphEdge` must implement the `weight` getter, which must return a `Weight` value of the weighted edge instance.
Moreover the method `reversedWith(weight:)` must be implemented. Such method must return an inverted edge in regards to its `either` and `other(either)` values as specified for `GraphEdge` protocol, but allowing to modify the `weight` value of the returned edge.
That is a type conforming to `WeightedGraphEdge` protocol must implement `reversed()` method so that the returned edge will have the same `weight` value of the callee; in order to obtain a reversed edge with a different weight value than the callee, the `reversedWith(weight:)` method must be used.

### `WeightedGraphEdge` equality, hashing and undirected comparison operator `<~>`
Default implementations of equality comparison and hashing consider also the `weight` value of  instances. 
The undirected comparison operator `<~>`, on the other hand, **will not** take into account the `weight` value of instances, thus supposing `e.either == v`, `e.weight == x` , `e.other(e.either) == w` and `d.either == w`, `d.other(w) == v`, `d.weoght == y` then:

```Swift
e <~> d
// RETURNS TRUE
```
### `WeightedGraphEdge` undirected weighted comparison operator `<=~=>`
To compare two weighted edges as undirected edges taking into account also the weight of the two edges, `WeightedGraphEdge` protocol provides the default implemented infix operator `<=~=>`.
This operator will return `true` when the two compared weighted edges are *undirected equivalent* and have the same `weight` value:

```Swift
let revE = e.reversed()

e <=~=> revE
// RETURNS TRUE

// Assuming e.weight == x and y!= x, then:
let revEW = e.reversedWith(weight: y)

e <~> revEW
// RETURNS TRUE

e <=~=> revEW
// RETURNS FALSE
```
## Type erasure
Type-erased wrappers for `Graph`, `GraphEdge` and `WeightedGraph` protocols are included in this package.

### `AnyGraph` type-erased wrapper
An `AnyGraph` instance forwards its operations to a base graph having the same `Edge` type, hiding the specifics of the underlaying graph.

You can create an instance of `AnyGraph` using one of the two initializers it provides:
the `Graph` protocol initializer `init(kind:edges:)`, or by using the `init(_:)` initializer which takes a concrete graph instance to wrap.

### `AnyGraphEdge` type-erased wrapper 
An `AnyGraphEdge` instance forwards its operations to a base edge, hiding the specifics of the underalying edge.

You can create an instance of `AnyGraphEdge` by adopting one of the following initializers:
* `init(_:)` which takes a concrete edge instance to wrap.
* `init(vertices:)` which takes a tuple containing the two vertices the edge connects, as if the  created edge would be an undirected connection in a graph.
* `init(tail:head:)` which takes the two connected vertices in order as its parameters `tail` and `head`, as if the created edge would be a directed connection in a graph. 

### `AnyWeightedGraphEdge` type-erased wrapper
An `AnyWeightedGraphEdge` instance forwards its operations to a base weighted edge having the same `Weight` type, hiding the specifics of the underlaying weighted edge.

You can create an instance of `AnyWeightedGraphEdge` by adopting one of the following initializers:
* `init(_:)` which takes a concrete weighted edge instance to wrap.
* `init(vertices:weight:)` which takes as its parameters a tuple containing the two vertices the edge connects and the weight of the edge, as if the created edge would be an undirected connection in a graph.
* `init(tail:head:weight:)` which takes the two connected vertices in order as its parameters `tail` and `head` plus the weight of the edge, as if the created edge would be a directed connection in a graph.

## Concrete types
Concrete types conforming to `MutableGraph`, `GraphEdge` and `WeightedGraphEdge` are also included in this package.

### `AdjacencyList` mutable graph value type
A mutable graph, generic over the `Edge` type and adopting as storage for its edges an adjacency list.

### `UnweightedEdge` graph edge value type
An unweighted edge of a graph.

### `WeightedEdge` weighted graph edge value type
A weighted edge of a graph, generic over the `Weight` type.

## Graph Utilities
Since graphs can have a huge number of vertices and edges it's better to isolate utilities operating over a graph in seprate ad independent code units. 
Graph utilities in this package are swift classes operating on a graph given at initialization time and building lazily their results when queried. 
This imply that when a graph mutates, any of these utilities have to be bulit again with the new graph resulting from the mutation, thus having to recalcutale any queried result.
The approach of having these utilities calculate lazily their queried results has the advantage of making failry inexpensive to create instances, postponing the heavy computations needed to calculate their data to the time a query is firstly made.
Even though linear complexity algorithms are used in these utilities to calculate their data, these computations can be highly expensive: by isolating them in independent classes these computations can also be safely dispacthed to a different thread.

### `GraphBipartite`
This utility is queried to check wheter a graph is two colors colorable or not.
You create a new instance by utilizing its initializer `init(graph:)`, passing the graph instace to query for being bipartite. 
Availbale graph queries: 
* `isBipartite` lazy getter, a boolean value either `true` if the graph is two colors colorable, or `false` otherwise.
* `countOfColoredVertex` lazy getter, an `Int` value representing the count of vertices colored in the graph after the bipartite detection.
* `countOfNotColoredVertex` lazy getter, an `Int` value representing the count of vertices not colored in graph after the bipartite detection.
* `isColored(_:)` method, which takes a vertex of the graph and returns a boolean value according to the color state of such vertex after the bipartite detection.

Every query builds the data in the utility for all other ones too the first time is called.

### `GraphCycle`
Query a graph for checking if it contains a cycle or not.
Create an instance of this utility by adopting the initializer `init(graph:)` which takes as its argument the graph instance to query for cycle detection.
Available graph queries: 
* `hasCycle`  getter (leverages on lazy getter `cycle`), returns a boolean value signaling the presence or not of a cycle in the queried graph.
* `cycle` lazy getter, returns an array containing the vertices representing the detected cycle in the queried graph. 
* `topologicalSort` lazy getter, returns an optional array of vertices and is `nil` when the graph is directed graph with a cycle or an undirected graph (that is for undirected graphs the topological sort doesn't exist), or the vertices in topological sort order when the queried graph is a *DAG*.

Every query builds the data in the utility for all other ones too the first time is called.

Additionally when the queried graph has weighted edges, `GraphCycle` instance has the method
`shortestsPaths(from:)` which given a `source` vertex, will optionally return a `GraphAcyclicSP`
utility for quering shortest paths in a directed acyclic graph. That is in case the queried graph is a
weighted edge directed acyclic graph, it is also possible to calculate shortests paths using its
topological sort.

### `GraphDegrees`
This utility is used to query a graph for degrees of its vertices and other statistic.
A `GraphDegrees` instance can be obtained via its initializer `init(graph:)`,  which takes as its argument the graph intance to query.
Available graph queries:
* `allEdges` lazy getter, which returns an array containing all the edges of the queried graph in respect to its `kind` value. That is, when the queried graph is of kind `.undirected`, the returned array  contains the edges in the graph representing the *undirected* connection between vertices. On the other hand,  when the queried graph has a `kind` value of `.directed`, the retunred array contains the edges representing a *directed* connection between vertices in the queried graph.
* `maxOutdegree` lazy getter. Returns an `Int` value representing the maximum outdegree value of a vertex in the queried graph.
* `averageOutdegree` lazy getter. Returns a `Double` value representing the average outdegree for a vertex in the queried graph.
* `countOfSelfLoop` lazy getter. Returns the number of edges in the graph representing a self-loop on a vertex.
* `outdegree(of:)` method, which takes a vertex of the queried graph as its argument, and returns its outdegree value.
* `indegree(of:)` method. Takes a vertex of the queried graph as its argument, and returns its indegree value.

Queries in this utility are independent to each other in regards of building the data for its results.

### `GraphPaths`
Query a graph and a source vertex in it for paths to destination vertices in such graph, adopting a specified graph traversal methodology.
Create a new `GraphPaths` instance by using the initializer `init(graph:source:buildPathsAdopting)`. This initializer takes a graph instance to query, a source vertex of such graph and a `GraphTrabversal` value that would be the chosen strategy to traverse the queried graph from the given source vertex to find a path to a destination vertex.
Available queries:
* `hasPath(to:)` method: takes a vertex of the queried graph as its parameter, and returns a bool value signaling the presence in the queried graph of a path connecting the queried source vertex to such given destination vertex.
* `pathFromSource(to:)` method. This method takes as parameter a vertex in the queried graph, and returns an array eventually containing the vertices to traverse in the queried graph from the queried source vertex to the given destination vertex if such path exists, otherwise an empty array if such path doesn't exists in the queried graph.

### `GraphReachability`
Query a graph from reachability from a set of its vertices to a given destination vertex.
To create a new `GraphReachbality` instance use the initalizer `init(graph:source:)` which takes as its arguments the graph to query and a set containing the graph vertices sources. The `sources` parameter must contain at least one vertex of the queried graph, otherwise a run-time error occurs.
This utility offers only one query: `isReachableFromSources(_:)` method, which takes a vertex in the queried graph and returns a boolean value: `true` when in the queried graph it is possible to reach such given destination vertex from the queried source vertices, otherwise `false`.
The internal data of this utility is calculated lazily the first time a query is made; that is after the first query is made, any subsequent query will take O(1) complexity to complete.

Moreover `Graph` protocol provides two default implemented methods which serve the same purpose of the `GraphReachablity` utility:
* `isReachable(_:source:)`
* `isReachable(_:sources:)`

Note that these two methods take O(*V* + *E*) complexity for every query, even when the source/sources parameter is used subsequentially more times. 
Thus it's recommended to use `GraphReachablity` utility when is clear that the same graph and source/sources vertices are gonna be queried for reachability more times.

### `GraphStronglyConnectedComponents`
This utility provides functionalities for querying a graph's strongly connected components. 
It can be used with graph with both kind of vertices connections, directed or undirected.
When an undirected graph is queried, this utility will build the connected componets adopting the classical deep-first-search approach, effectively creating connected components for the graph. 
When a directed graph is queried, it will use the *Kosaraju-Sharir algorithm* to instead build **strongly** connected components of such graph: that is all vertices inside such component can be reach from the other ones.
Create a new `GraphStronglyConnectedComponents` instance by using the initializer `init(graph:)`, which takes the graph instance to query for strongly connected components.
Available queries:
* `count` a lazy getter returning the number of strongly connected components of the queried graph.
* `areStronglyConnected(_:_:)` method. Takes as argument two vertices oncluded in queried graph and return a boolean value: `true` when the two vertcies are strongly connected (that is there is a path in the queried graph going from the first vertex to the second vertex and vice-versa), `false` otherwise. 
* `id(of:)` method, which take as parameter a vertex incliuded in the queried graph, and returns an `Int` value in range `0..<count` which represents the *id* of the strongly connected component where such vertex resides in the queried graph.
* `stronglyConnectedComponent(with:)` method. Takes as its argument an `Int` value in range `0..<count` which represent the *id* of the strongly connected component to obtain, and returns an array containing the vertices in the queried graph residing in the strongly connected component with such given *id*.
* `verticesStronglyConnected(to:)` method. This query takes as its argument a vertex included in the queried graph, and returns an array containign all vertices of the queried graph strongly connected to. Such result will also include the given vertex itself, since every vertex in a graph is suppossed to be strongly connected to itself.

Every query listed above will trigger the utility to build its internal data used also by the other queries. That is, after a first query is done, every other query permformed will take O(1) complexity to complete, aside for the last two listed above, that return a strongly connected component contents and which are listed as O(*V*) complexity, where *V* is the count of vertices in the queried graph. 
Practically these two methods memoize the strongly connected components inside a cache, thus they may perform in amortized O(1) complexity when a result has been already constructed for an another query made earlier. 

### `GraphTransitiveClosure`
Create this utility by using the initializer `init(graph:)`, which takes the graph to query as its parameter. Then query it for reachablity from a source vertex to another destination vertex (both must be in queried graph) via the instance method `rachability(source:destination:)` , which returns a boolean value as result.
The *transitive closure* is usallly used for directed graphs, although this utility can be built with both
directed or undirected graphs. 
* When the queried graph is undirected, then internally the utility will just adopt the connection components of the graph to determine vertices reachability: that is in an undirected graph all vertices in the same connected component are connected to each other. Such connected components for the queried graph are built the first time a query is made, and are valid for every vertex in the graph used as source parameter.
* For queried directed graphs , the utility builds the reachability map from the given `source` vertex and check if it contains the given `destination` vertex. Such map for the given `source` vertex gets memoized after being built the first time, thus when querying again the same `source` vertex for reachability towards another `destination` vertex, it gets most likely reused avoiding the process of rebuilding it. Note that these reachability maps for every `source` vertex are individually and lazily built the first time such vertex is queried.

### `GraphMSF`

### Shortest paths utilities

### FlowNetwork
