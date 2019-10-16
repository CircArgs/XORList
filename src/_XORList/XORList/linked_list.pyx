from libc.stdint cimport uintptr_t

cdef class Node:
    def __init__(self, object val, uintptr_t prev_xor_next=0):
        self.prev_xor_next=prev_xor_next
        self.val=val

    def __repr__(self):
        return str(self.val)

cdef class CurrentNode(Node):
    def __init__(self, Node node, uintptr_t prev_ptr=0):
        self.node=node
        self.prev_ptr=prev_ptr

    cpdef CurrentNode forward(self):
        if self.node.prev_xor_next:
            return CurrentNode((self.node.prev_xor_next^self.prev_ptr)[0], &self.node)

    cpdef CurrentNode backward(self):
        if self.prev_ptr:
            return CurrentNode(self.prev_ptr[0], (&self.node)^(self.prev_ptr[0]).prev_xor_next)

cdef class XORList:
    cdef Node first, last, current

    cpdef append(self, object val):
        if not first:
            self.first=CurrentNode(Node(val))
            self.last=self.first
            self.current=self.first
        else:
            if last==first:
                self.last=CurrentNode(Node(val))
                self.first.node.prev_xor_next=(&self.last.node)^self.first.prev_ptr
                self.first=self.first.node
                self.last.prev_ptr=&self.first
            else:
                temp=CurrentNode(Node(val))
                self.last.node.prev_xor_next=(&self.temp.node)^self.last.prev_ptr
                self.temp.prev_ptr=&self.last
                self.last=temp

    cpdef reverse(self):
        temp=self.last
        self.last=self.first
        self.first=temp

    def __iter__(self):
        return self
    
    def __next__(self):
        if not self.current or not self.current.forward():
            self.current=CurrentNode(self.first)
            raise StopIteration()
        ret = self.current
        self.current=self.current.forward()
        return ret

    def __repr__(self):
        cdef str ret =''
        for i in self:
            ret+='<->'+str(i)
        return ret