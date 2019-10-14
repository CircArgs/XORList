#add source to sys path
import sys
import os
sys.path.append(os.path.join(os.path.dirname(os.path.realpath(__file__)), "../src"))

#testing pluggins
from hypothesis import given
import hypothesis.strategies as st

#testing below
from XORList import hello

@given(st.text())
def test_hello(s):
   assert f'Hello {s}'==hello.say_hello_to(s)