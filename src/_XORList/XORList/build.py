from distutils.core import setup, Extension
from Cython.Build import cythonize

ext = Extension("RNG", sources=["Rectangle.pyx", "Rectangle.cpp"], language="c++")
setup(name="RNG", ext_modules=cythonize(ext))