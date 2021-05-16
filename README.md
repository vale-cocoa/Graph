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
Type conforming to `Graph` protocol must also define the getter `edgeCount`, which must return a non negative `Int` value repressnting the total number of edges present in the graph instance, in respect to the `kind` value of such instance. 
As mentioned before, since the direction of connections between vertices in a graph is defined by its `kind` getter, the number of edges present in a graph instance via the getter `edgeCount` must take into account such value. That is for an undirected graph, the value returned by `edgeCount` must count an adjacency between a vertex `v` and `w` as one undirected edge and not as two directed edges.
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
Note that this method should also return self loops in the array, if the given vertex as any set in the graph.

### Reversing a graph
`Graph` protocol defines also the method `reversed()`, which should return the *inversion* of a graph instance. 
When a graph instance has its `kind` value equal to `.directed`, then this method should returned another graph instance with its `kind` value equal to `.directed`, but with the edges of the calee in inverted direction. On the other hand for graph instances with `kind` value equal to `.undirected`, this method might as well just return the same graph instance, since inverting an undirected graph will produce the same graph.

### `Graph` equality and hashing
`Graph` protocol has its default implementation for equality comparison of two instances taking into account the order of edges in the arrays returned by the `adjacencies(vertex:)` method on every vertex; this very same beahvior is reflected by the default `Hashable` implementation.

## Traversing a `Graph`
`Graph` protocol defines some methods with default implementations for traversing a graph.
These methods have a *Functional Programming* approach, and take one or more non escaping closures that will be executed during the traversal of the graph, passing as parameters to them vertcies and/or edges encountered during such traversing.
Some of these methods also give the opportunity to the caller to specify the traversal strategy to adopt,
by getting as parameter a `GraphTraversal` value.

### Visit every vertex of a graph
Both methods `visitEveryVertexAdjacency(adopting:_:)` and `visitAllVertices(adopting:_:)` will visit every vertex in the graph instance, regardless if any of the vertex is disconnected in the graph. 
These methods will start at vertex `0` of the graph, proceeding on the adjacencies by adopting the given traversal strategy, and then keep visiting those vertices not touched by the traversal of the previous vertex taken into account, until every vertex in the graph has been visited.
Note that adjacencies leading to vertices already being visited during the traversal are not enumerated.
Therefore the method executing a closure receiving the visited vertex and an edge from its adjacencies as parameter will only execute such closure for adjacencies leading to vertices not yet visited, and will not enumerate parallel edges or self-loop edges. 

### Visited vertices starting from a source vertex
Methods with signature `visitedVertices(adopting:reachableFrom:_:)` will proceed from the given `source` vertex on adjacencies only, by then returning a set containig all the vertices visited during the traversal. Thus these two methods will stop after every vertex discoverable in the graph starting from the given source has been visited. 
Note that adjacencies leading to vertices already being visited during the traversal are not enumerated.
Therefore the method executing a closure receiving the visited vertex and an edge from its adjacencies as parameter will only execute such closure for adjacencies leading to vertices not yet visited, and will not enumerate parallel edges or self-loop edges. 

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

### `UnweightedEdge` graph edge value type

### `WeightedEdge` weighted graph edge value type

## Graph Utilities
