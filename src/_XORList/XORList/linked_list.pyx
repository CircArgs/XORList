#TODO: reference counting
#https://stackoverflow.com/questions/58431732/cython-memory-efficient-doubly-linked-list

from cpython.object cimport PyObject
from cpython.ref cimport Py_XINCREF, Py_XDECREF
from libc.stdint cimport uintptr_t

cdef class Node:
    cdef int prev_xor_next
    cdef object val
    def __init__(self, object val, uintptr_t prev_xor_next=0):
        self.prev_xor_next=prev_xor_next
        self.val=val

    def __repr__(self):
        return str(self.val)


cdef class CurrentNode(Node):
    cdef uintptr_t node, prev_ptr
    def __init__(self, uintptr_t node, uintptr_t prev_ptr=0):
        self.node = node
        self.prev_ptr= prev_ptr
        
        
    @property
    def Node(self):
        ret=<PyObject *> self.node
        return <Node> ret
    
    cpdef CurrentNode forward(self):
        if self.Node.prev_xor_next:
            return CurrentNode(self.Node.prev_xor_next^self.prev_ptr, self.node)

    cpdef CurrentNode backward(self):
        if self.prev_ptr:
            return CurrentNode(self.prev_ptr, (self.node)^(self.prev_ptr).prev_xor_next)

cdef class XORList:
    cdef PyObject* first
    cdef PyObject* last
    cdef PyObject* current

    cpdef append(self, object val):
        #empty list
        if not self.first:
            t=Node(val)
            tp=<uintptr_t> (<PyObject*> t)
            new=CurrentNode(tp)
            self.first=<PyObject*> new
            self.last=self.first
            self.current=self.first
        #not empty
        else:
            #one element
            if self.last==self.first:
                t=Node(val)
                tp=<uintptr_t> (<PyObject*> t)
                new=CurrentNode(tp)
                self.last=<PyObject*> new
                t=<Node> self.first
                prev_xor_next=<uintptr_t> (<uintptr_t> (<Node> self.last).node)^(t.prev_ptr)
                t=<Node> (<PyObject*> t.node)
                t.prev_xor_next=prev_xor_next
                self.first=<PyObject*> ((<Node> self.first).node)
                t=<Node> self.last
                t.prev_ptr=<uintptr_t> self.first
            #more than one element
            else:
                t=Node(val)
                tp=<uintptr_t> (<PyObject*> t)
                temp=CurrentNode(tp)
                t=<Node> self.last
                prev_xor_next=(self.temp.node)^(t.prev_ptr)
                t=<Node> (<PyObject*> t.node)
                t.prev_xor_next=prev_xor_next
                self.temp.prev_ptr=<uintptr_t> self.last
                self.last=<PyObject*> temp

    cpdef reverse(self):
        temp=self.last
        self.last=self.first
        self.first=temp

    def __iter__(self):
        return self
    
    def __next__(self):
        
        if not self.current or not (<CurrentNode> self.current).forward():
            t=<uintptr_t> self.first
            cn=CurrentNode(t)
            self.current=<PyObject*> cn
            raise StopIteration()
        ret = <CurrentNode> self.current
        fr=ret.forward()
        self.current=<PyObject*> fr
        return ret

    def __repr__(self):
        cdef str ret =''
        for i in self:
            ret+='<->'+str(i)
        return ret
    
l=XORList()
l.append(1)
print(l)
