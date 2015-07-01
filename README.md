# CKMathParser
CKMathParser is a **math expression parser** built with the **Swift 2.0** programming language by Apple Inc.

#### Goals For The Project
* Build a functional math parser framework importable into iOS projects
* Support all of the basic operators (+, *, ^, etc)
* Support major singe parameter functions (sin, cos, log, etc)
* Support major fundamental constants (e, pi, etc) and user defined constants.
* Be easily extensible to add support for more functions and constants
* Provide meaningful error messages

#### Be Warned!
Currently my code is extremely dirty and incomplete. I have been going back and forth between different parsing methods and optimizations. I want to have a very readable, well commented, and error free program so just give me some time to sort it out.

#### Current Problem Expressions
* Negating something in paranthases: -(1+2)
#### Installing CKMathParser
While the end goal is to convert this project to an importable framework, for testing purposes the appropriate .swift files are contained in a test iOS project. If you want to try out the parser now with its limited functionality, instructions are as follows:

1. Download the repo as a .zip
2. Open CKMathParser-iOS > CKMathParser-iOS
3. Copy CKMathParser.swift and import it into your own project

#### Contributors
So far the only contributor is me, Connor Krupp, but if you want to help out feel free to submit an issue or ask for a pull request!

#### License
The MIT License (MIT)

Copyright (c) 2015 Connor Krupp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#### Documentation
Documentation will eventually be in the wiki but first I have to finish basic functionality.



