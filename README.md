[TOC]

# 简介

# 使用方式
- 当需要添加非原理性功能时，将此IP拷贝到相应的工程文件夹并做相应的修改，作为变种存在。
# 目录及文件

```
    IP_NAME
        ├── .img/
        ├── algo/
        ├── doc/
        ├── mcs/
        │	├── utility/
        │	└── verify/
        ├── proj/
        │	├── utility/
        │	├── verify/
        │	├── utility.tcl
        │	└── verify.tcl
        ├── src/
        │	├── sim/
        │	├── utility/
        │	│	├── coe/
        │	│	├── driver/
        │	│	├── hdl/
        │	│	├── mem/
        │	│	└── xdc/
        │	└── verify/
        │	│	│
        │	└──	└── vitis/
        ├── .gitignore
        └── .README.md
```

## 目录简介

***如果用不到相应目录就将其删除***

- .img，image目录，这是一个隐藏文件夹，包含README.md中用于解释说明的图片；
- algo，algorithm目录，包含了此IP的数学算法代码、IP中查表初始化文件生成脚本（.coe、.mem等），IP源码的生成脚本等；
- doc，document目录，包含了设计此IP时参考的文档；
- mcs，编译结果目录，包含.dcp、.bit、.xsa等编译结果；
  - utility，IP源码的综合结果，用于提供IP综合网表；
  - verify，IP验证代码编译或综合结果，利于Git切换版本时无需重新编译或综合；
- proj，project目录，包含IP所需的Vivado工程与Vivado工程重建脚本（.tcl文件）；
  - utility，IP Vivado工程，用于打包IP以及启动IP仿真，**此目录中工程名与IP名同名**（为了driver目录中代码被export到Vitis中文件夹为IP名）；
  - verify，IP Vivado验证工程，将IP部署于FPGA上用于验证功能正确性的简单测试平台，**此目录中工程名为verify**；
- src，source目录，包含组成IP的各类代码；
  - sim，用于IP仿真的激励；
  - utility，IP的功能源码；
    - coe，包含.coe文件，rom、ram IP初始化文件目录；
    - driver，包含.c、.h、Makefile、.mdd、.tcl等文件，SDK或Vitis中驱动配置代码目录；
    - hdl，包含.v、.vhd文件，逻辑源码目录；
    - mem，包含.mem文件，xpm rom ram 初始化文件目录；
    - xdc，包含.xdc文件，约束文件目录；
  - verify，IP验证平台激励；
    - vitis，vitis代码及工程目录；

## 文件简介

- .gitignore，记录不需要进行Git版本控制的文件及文件夹；
- README.md，解释IP的功能、使用方法、更新维护流程等；
- utility.tcl，用于重新生成utility Vivado工程（详情见Git版本控制）；
- verify.tcl，用于重新生成verify Vivado工程（详情见Git版本控制）；

# Git版本控制

Vivado工程在综合、仿真时会产生大量中间文件，可以很轻易到达1GB，对其直接进行Git版本控制不现实。
因此，保存其编译结果（msc目录）、导出其重建脚本（utility.tcl、verify.tcl）、再将工程本身通过.gitignore剔除，即可完成对Xilinx Vivado工程进行Git版本控制。

## Vivado 生成重建脚本

打开Vivado工程，在其Tcl Console中输入如下命令：

- 不包含.bd文件的工程的重建脚本生成流程：
```tcl
#1. 将命令行目录移到当前工程目录
cd [get_property directory [current_project ]]
#2. 将脚本命令行目录移到上级目录（proj目录）
cd ..
#3. 生成tcl_name.tcl
write_project_tcl -force -no_copy_sources -origin_dir_override ./ -paths_relative_to ./ -target_proj_dir ./dir_name/ tcl_name.tcl
#4. 将工程文件夹重命名，运行重建脚本，查看是否得到同样的工程；
```

- 包含.bd文件的工程的重建脚本生成流程：
```tcl
#1. 将命令行目录移到当前工程目录
cd [get_property directory [current_project ]]	
#2. 将脚本命令行目录移到上级目录（proj目录）
cd ..
#3. 生成tcl_name.tcl
write_project_tcl -force -no_copy_sources -use_bd_files -origin_dir_override ./ -paths_relative_to ./ -target_proj_dir ./dir_name/ tcl_name.tcl	
#4. 重命名工程文件夹，运行tcl_name.tcl，删除运行时报错的代码段（即添加.bd文件的代码段；因为没有找到.bd文件，所以报错了）；
#5. 打开工程的.bd文件，File-Export-Export Block Design，导出.bd文件的重建脚本文件；
#6. 将如下脚本添加到tcl_name.tcl末尾，再将.bd文件重建脚本代码复制到其后；
set_property source_mgmt_mode All [current_project]
#7. 添加生成.bd文件的wrapper脚本到tcl_name.tcl末尾：
cd [get_property directory [current_project ]]
make_wrapper -files [get_files ./proj_name.srcs/sources_1/bd/bd_name/bd_name.bd] -top
add_files -norecurse ./proj_name.gen/sources_1/bd/bd_name/hdl/bd_name_wrapper.v
#8. 将工程文件夹重命名，运行重建脚本，查看是否得到同样的工程；
```

## 重建脚本的使用

```tcl
#1. 打开Vivado或Vivado Tcl Shell，输入命令（注意目录不可以用\，只能使用\\或者/）:
cd path_of_tcl_file
#2. 输入命令
source tcl_name.tcl；
```