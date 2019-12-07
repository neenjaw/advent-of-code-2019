package orbit

type fifo struct {
	queue []*fifoNode
}

type fifoNode struct {
	node     *Body
	distance int
}

func newFifo() *fifo {
	return &fifo{
		queue: make([]*fifoNode, 0),
	}
}

func (f *fifo) length() int {
	return len(f.queue)
}

func (f *fifo) enqueue(node *Body, distance int) {
	fnode := fifoNode{node, distance}
	f.queue = append(f.queue, &fnode)
}

func (f *fifo) dequeue() (*Body, int) {
	if len(f.queue) == 0 {
		return nil, -1
	}

	fnode := f.queue[0]
	f.queue[0] = nil
	f.queue = f.queue[1:]

	return fnode.node, fnode.distance
}
