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
        if self.node.prev_xor_next!=self._prev_ptr:
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
    cdef int length
    
    def __init__(self):
        self.length=0
    @property
    def head(self):
        return (<Node> self.first)
    
    @property
    def tail(self):
        return (<Node> self.last)
    
    cpdef append(self, object val):
        self.length+=1
        #empty list
        if not self.first:
            t=Node(val)#we create our very first node
            tp=(<PyObject*> t)#we get a pointer to it
            self.first=tp#finally we set our first node to our new current
            Py_XINCREF(tp)#+1 ref first
            self.last=tp#since this is our first node it is our first and last
            Py_XINCREF(tp)#+1 ref last

        #not empty
        else:
            new_node=Node(val, <uintptr_t> self.last)
            new_ptr=<PyObject*> new_node
            cur_last=<Node>self.last
            cur_last.prev_xor_next=cur_last.prev_xor_next^(<uintptr_t> new_ptr)
            Py_XINCREF(new_ptr)#+1 ref prev_xor_next
            self.last=new_ptr
            Py_XINCREF(new_ptr)#+1 ref last

    cpdef reverse(self):
        temp=self.last
        self.last=self.first
        self.first=temp

    def __repr__(self):
        return str(list(iter_XORList(self)))
    def __len__(self):
        return self.length
    
def iter_XORList(l):
    head=<PyObject*>l.head
    cur=CurrentNode(<uintptr_t> head)
    while cur:
        yield cur
        cur=cur.forward()
        
    
# first=Node(1)
# cdef PyObject* fp=<PyObject*>first
# second=Node(2)
# cdef PyObject* sp=<PyObject*>second

# third=Node(3)
# first.prev_xor_next=<uintptr_t>sp
# Py_XINCREF(sp)
# del second

# start=CurrentNode(<uintptr_t> fp)
# print(isinstance(start, Node))
# print(start)
# print(start.forward())
# print(start.forward().backward())
# # print(<Node>sp)
# import time

# start=time.time()
# l=XORList()
# for i in range(1000):
#     l.append(i)
# print('time xor ', time.time()-start)
# print(len(l))
# start=time.time()
# l=[]
# for i in range(1000):
#     l.append(i)
# print('time regular ', time.time()-start)
