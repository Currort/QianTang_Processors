

# 当前目标

实现基础数据通路：+、-

# 五级流水线乱序超标量CPU

## 取指 IF instruction fetch

* [X] PC 程序计数器
* [X] IM 指令存储器
* [ ] 相关逻辑实现
* [ ] 预译码

## 译码 ID instruction decode

* [X] ID                           指令译码器
* [X] RegFile                   寄存器堆
* [X] RISCV_instruction   RISCV相关指令以及CPU配置头文件
* [ ] 相关逻辑实现
* [ ] 预执行
* [ ] 静态多发射
* [ ] 动态多发射

## 执行 EX execute

* [X] CLA 利用4位CLU，3次超前进位实现64位加法器
* [ ] ALU 算术逻辑单元，指令相关逻辑实现
* [ ] 相关逻辑实现

## 访存 MEM memory

* [ ] Cache 缓存，加速内存读取
* [ ] MEM   普通Memory，直接存取

## 写回 WB write back

* [ ] WB 写入寄存器、内存、控制寄存器中

## 外设总线 待定...
