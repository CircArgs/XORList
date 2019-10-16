from distutils.core import setup
from Cython.Build import cythonize

setup(name='A XOR Memory Efficient Doubly-Linked List',
      ext_modules=cythonize("Rectangle.pyx"))