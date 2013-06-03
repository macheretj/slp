SLP - SSH Single Login Point Project
===

Introduction
--------

This project aims to automate ssh-agent mechanism for users and provide a secured single point of login.

Overview
--------

![SLP Overview schema](https://www.lucidchart.com/publicSegments/view/51abe29b-f344-465c-b2b9-29720a005a97/image.png "SLP Overview schema")

TODO before alpha version
===

PRIORITARY:
- find a better way to work with ssh-agent processes
  - use of arrays
    - sort processes within arrays
  - avoid using ps command more than once

SECONDARY:
- Full documentation
  - comment the code
- implement client side
- install apache2 on server side
  - document install and vhost config
  - script apache2 config
- test server side fully
  - review code
    - make it standard
    - use variable for everything in the code
    - reorganize
  - try to make unit test style test rountines
- much more

