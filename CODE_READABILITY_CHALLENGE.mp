## Exercise: Making code easier to read (Code Readability Challenge)

**Example 2: Missing Documentation (Python)**

I ran the test for the python function that has to perform calculations for financial application using the Unit Test, but the test failed. 

Failed test:
```
$ py -m unittest test_calculator.py
..F.
======================================================================
FAIL: test_with_additional_contributions (test_calculator.TestCompoundInterestCalculator.test_with_additional_contributions)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "C:\WETHINKCODE-MY REPOSITORY\ai-code-exercises\test_calculator.py", line 19, in test_with_additional_contributions
    self.assertAlmostEqual(result["final_amount"], 2234.51, places=2)
    ~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: 2239.52 != 2234.51 within 2 places (5.0099999999997635 difference)

----------------------------------------------------------------------
Ran 4 tests in 0.007s

FAILED (failures=1)
```


