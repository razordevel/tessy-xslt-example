This project provides some infrastructure to develop [XSL transformations](https://www.w3schools.com/xml/xsl_intro.asp).

It its intended as an example for customers of Razorcat TESSY which wants to process XML reports created by TESSY. 

Please fork this repository and add or modify transformations as needed.

h2. Add another XSL Script

* create a script `MY_SPECIAL_FORMAT.xsl` in `src/main/xslt`
* create a folder `MY_SPECIAL_FORMAT` in `src/test/xslt`
* create a folder `testcase_x` for every test in `src/test/xslt/MY_SPECIAL_FORMAT` which includes 
 * an `input.xml` which is used as the input for the transformation
 * an `expected.xml` which is used in the test as the expected output
