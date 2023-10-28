# computer_architecture_hw2
Note:This .c file only work on rv32emu, can't work on VScode. Because VScode doesn't support  some command in getticks function(or I don't know?)</br>
<h2>How to run on rv32emu:</br></h2>
<h4>&emsp; Using .c file to generate .elf file</h4></br>
&emsp;&emsp; 1. Changing Makefile_for_C filename to Makefile</br>
&emsp;&emsp; 2. Make sure your c.file, Makefile and ld.file under the same folder</br>
&emsp;&emsp; 3. Terminal execute "Make" command</br>
&emsp;&emsp; 4. Terminal execute "../../../build/rv32emu hugohw.elf". Left part you need to check your rv32emu.exe path</br>
</br>

<h4>&emsp; Using .S file to generate .elf file</h4></br>
&emsp;&emsp; 1. Changing Makefile_for_S filename to Makefile</br>
&emsp;&emsp; 2. Make sure your S.file, Makefile and ld.file under the same folder</br>
&emsp;&emsp; 3. Terminal execute "Make" command</br>
&emsp;&emsp; 4. Terminal execute "../../../build/rv32emu hugohw.elf". Left part you need to check your rv32emu.exe path</br>
