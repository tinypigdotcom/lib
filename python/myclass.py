#!/usr/bin/python3

class Dog:

    kind = 'canine'         # class variable shared by all instances

    def __init__(self, name):
        self.name = name    # instance variable unique to each instance
        self.distance = 0

    def bark(self):
        print(self.name, ": ruff! ruff!", sep="")

    def report_distance(self):
        print(self.name, "has walked", self.distance, "feet.")

    def walk(self,distance=1):
        self.distance += distance
        self.report_distance()

    def go_home(self):
        self.distance = 0
        print(self.name, "has gone home. ", end="")
        self.report_distance()

if __name__ == '__main__':
    import unittest

    class IsOddTests(unittest.TestCase):

        def setUp(self):
            self.d = Dog('Fido')

        def testOne(self):
            self.assertTrue(self.d.kind == 'canine')

        def testTwo(self):
            self.assertTrue(self.d.name == 'Fido')

        def testThree(self):
            f = Dog('Fido')
            self.assertTrue(f.name == 'Fido')

    unittest.main()

