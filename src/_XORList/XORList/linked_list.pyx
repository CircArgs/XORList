# %%cython

#TODO: reference counting
#https://stackoverflow.com/questions/58431732/cython-memory-efficient-doubly-linked-list

from cpython.object cimport PyObject
from cpython.ref cimport Py_XINCREF, Py_XDECREF
from libc.stdint cimport uintptr_t

cdef class Node:
    cdef uintptr_t _prev_xor_next
    cdef object val
    
    def __init__(self, object val, uintptr_t prev_xor_next=0):
        self._prev_xor_next=prev_xor_next
        self.val=val
        
    @property
    def prev_xor_next(self):
        return self._prev_xor_next
    @prev_xor_next.setter
    def prev_xor_next(self, uintptr_t p):
        self._prev_xor_next=p
    
    def __repr__(self):
        return str(self.val)


cdef class CurrentNode(Node):
    cdef uintptr_t _node, _prev_ptr
    def __init__(self, uintptr_t node, uintptr_t prev_ptr=0):
        self._node = node
        self._prev_ptr= prev_ptr
        
    @property
    def val(self):
        return self.node.val
    @property
    def node(self):
        ret=<PyObject *> self._node
        return <Node> ret
    @property
    def prev_ptr(self):
        return self._prev_ptr
    
    cpdef CurrentNode forward(self):
        if self.node.prev_xor_next:
            return CurrentNode(self.node.prev_xor_next^self._prev_ptr, self._node)

    cpdef CurrentNode backward(self):
        if self._prev_ptr:
            pp=<PyObject*>self._prev_ptr
            return CurrentNode(self._prev_ptr, self._node^(<Node> pp).prev_xor_next)
        
    def __repr__(self):
        return str(self.node)

cdef class XORList:
    cdef PyObject* first
    cdef PyObject* last
    cdef PyObject* current

    @property
    def Current(self):
        return (<CurrentNode> self.current).val
        
    cpdef append(self, object val):
        #empty list
        if not self.first:
            t=Node(val)
            tp=(<PyObject*> t)
            Py_XINCREF(tp)
            new=CurrentNode(<uintptr_t> tp)
            np=<PyObject*> new
            Py_XINCREF(np)
            self.first=np
            self.last=self.first
            self.current=self.first
        #not empty
        else:
            #one element
            if self.last==self.first:
                t=Node(val)
                tp= (<PyObject*> t)
                Py_XINCREF(tp)
                new=CurrentNode(<uintptr_t> tp)
                np=<PyObject*> new
                Py_XINCREF(np)
                self.last=np
                t=<CurrentNode> self.first
                prev_xor_next=<uintptr_t> ((<Node> self.last).node^t.prev_ptr)
                t=t.node
                t.prev_xor_next=prev_xor_next
                fp=self.first
                self.first=<PyObject*> (<Node> self.first).node
                Py_XDECREF(fp)
                t=<Node> self.last
                t.prev_ptr=<uintptr_t> self.first
            #more than one element
            else:
                t=Node(val)
                tp=<PyObject*> t
                Py_XINCREF(tp)
                temp=CurrentNode(<uintptr_t> tp)
                
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
    
first=Node(1)
cdef PyObject* fp=<PyObject*>first
second=Node(2)
cdef PyObject* sp=<PyObject*>second

third=Node(3)
first.prev_xor_next=<uintptr_t>sp
Py_XINCREF(sp)
del second

start=CurrentNode(<uintptr_t> fp)
print(isinstance(start, Node))
print(start)
print(start.forward())
print(start.forward().backward())
# print(<Node>sp)
