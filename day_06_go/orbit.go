package orbit

// Body a celestial body
type Body string

func (b *Body) String() string {
	return string(*b)
}

// Graph is a graph of orbits
type Graph struct {
	bodies map[Body]int
	edges  map[Body][]*Body
}

// AddNode adds a node to the graph
func (g *Graph) AddNode(n *Body) {
	if g.bodies == nil {
		g.bodies = make(map[Body]int)
	}
	g.bodies[*n] = -1
}

// AddUnidirectionalEdge adds a unidirectional edge to the graph
func (g *Graph) AddUnidirectionalEdge(n1, n2 *Body) {
	if g.edges == nil {
		g.edges = make(map[Body][]*Body)
	}
	g.edges[*n1] = append(g.edges[*n1], n2)
	// g.edges[*n2] = append(g.edges[*n2], n1)
}

func (g *Graph) String() string {
	s := ""
	for body := range g.bodies {
		s += body.String() + " -> "
		near := g.edges[body]
		for _, obj := range near {
			s += (*obj).String() + " "
		}
		s += "\n"
	}
	return s
}

// CalcChecksum does a BFS summing the distances from the origin to calculate the checksum
func (g *Graph) CalcChecksum(origin *Body) int {
	queue := newFifo()
	checksum := 0
	queue.enqueue(origin, 0)
	for queue.length() > 0 {
		node, distance := queue.dequeue()
		checksum += distance

		adjacent, ok := g.edges[*node]
		if !ok {
			continue
		}
		for _, a := range adjacent {
			queue.enqueue(a, distance+1)
		}
	}

	return checksum
}
