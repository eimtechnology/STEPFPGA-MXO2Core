# STEPFPGA-MXO2Core
The codes accompanied with STEPFPGA tutorial book

***An Experimental Discovery of Digital Circuits Implemented by FPGA*** for the STEPFPGA board. This book is an introductory level tutorial designed for FPGA beginners or students who have basic knowledge in digital circuits. 

Chapter 1 gives a quick review of the fundemental knowledge of logic gates, combinational and sequnetial circuits, state machin and AD/DA. In Chapter the contents go over the basic concepts of FPGAs, the design & implementation process with HDL, and also showing some techniques of circuit simulation and building. Chapter 3 and Chapter 4 help readers to get familar and comfortable with digtial design using Verilog coding with abundant experiments and exercises, and eventually they will get to real challenges with several fun building projects in Chapter 5.

Particularly, for Chapter 5 each folder contains All-in-one style and Separate style of coding.

- The All-in-one style integrates all modules into a single and long Verilog code, for quick demo or experiment purpose, you simply copy & paste the single file in your IDE tool and synthesis. 
- The Separate style is more structural and has complete codes for all sub-modules being used. Most of the submodules are compatible with the modules you used in Arduino projects.  

In all folders of Chapter 5, you noticed a **xxxxx.JED** file there. This is the final implementation bitstream file which you can simply drag into the STEPLink flashdrive, and the program automatically burns in. Using the pin definitions are specified in the pin-mapping images, you should be able to setup the demo.

If you are unfamilar with STEPFPGA WebIDE procedures, please check out two videos:
- https://www.youtube.com/watch?v=Hs74K9Sf7wA
- https://www.youtube.com/watch?v=1dwpKoTp4Zo

Nevertheless, if you are totally new to FPGA, all these stuff still make no sense to you, so the best way is to learn the systematic knowledge from fundamentals and go step by step until you are comfortable to play all these projects.

Enjoy a pleasant FPGA journey with this simple but power board, and of course, the tutorial and kits.

EIM Technology
