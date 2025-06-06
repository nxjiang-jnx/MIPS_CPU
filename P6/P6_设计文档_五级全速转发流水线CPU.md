# P6\_设计文档\_五级全速转发流水线CPU

## 命名规范

- 部件文件命名：`级+大写部件名`；实例化为`_+小写部件名`。例如文件名为 `F_PC` ，实例化为 `_pc` 。
- 每一级的控制信号和临时的 wire 均以本级的名称开头，如 `D_rs` 、`D_A1` 、`D_RD1` 。
- 流水线寄存器文件如 `FD_reg` ，实例化如 `_fd_reg` 。



## 注意细节

1. 书上说：如果beq要转移，那么需要清空D级寄存器。清空 `IF/ID` 寄存器的目的是**插入一个气泡（bubble）**，使分支后不再执行错误的指令。注意，这和延迟槽机制有一些区别：

| **特性**         | **延迟槽**                                   | **清空 `IF/ID` 寄存器**                    |
| ---------------- | -------------------------------------------- | ------------------------------------------ |
| **性质**         | 硬件与软件协作，编译器插入优化指令           | 完全由硬件控制，插入气泡                   |
| **实现方式**     | 编译器在延迟槽中插入有意义的或无操作指令     | 硬件插入 NOP，清空 `IF/ID` 寄存器          |
| **指令执行情况** | 延迟槽的指令**总是被执行，无论分支是否成立** | 清空后，延迟槽中的错误指令被替换为气泡     |
| **对性能的影响** | 需要依赖编译器优化，可能执行无关的指令       | 性能稍微下降，分支冒险处理需要暂停一个周期 |

<img src="E:\myFolder_3\COLab\P6\assets\image-20241117142657810.png" alt="image-20241117142657810" style="zoom:80%;" />

译码器识别到跳转指令时，指令已经到达 D 级（Instruction 2），此时位于跳转指令的下一条指令已经在 F 级被取出 (Instruction 1)；将译码器置于 D 级的架构导致我们**无法避免**取出这条多余的指令，**即使此时清空上一级寄存器，不执行这条多余的指令，也对提高效率于事无补。**我们的架构决定了我们在执行跳转指令时一定会额外执行一条指令。这就是所谓的”延迟槽“。**若在 D 级识别到跳转指令时将上一级寄存器清空，不执行这条多余的指令，这种行为被称作”清空延迟槽“。**

上述的两种机制分别对应着**延迟槽**和**清空延迟槽**。

我们的实验中，**不考虑清空延迟槽**。也就是不需要 `FlushD` 端口。

## 模块的定义

### F_PC

| 信号名 | 方向 |                             描述                             |
| :----: | :--: | :----------------------------------------------------------: |
|  clk   |  I   |                           时钟信号                           |
| reset  |  I   | **同步复位**信号。复位值为起始地址，**起始地址：0x00003000。** |
|  NPC   |  I   |         在时钟上升沿来临时，将要更新的新PC值，32位。         |
| F_PCEn |  I   |           PC写使能。如果为1，则NPC可以正常写入PC。           |
|   PC   |  O   |                        新PC值，32位。                        |

### F_NPC

| 信号名 | 方向 |                             描述                             |
| :----: | :--: | :----------------------------------------------------------: |
| NPCOp  |  I   | 3位功能选择信号。000：顺序执行；001：分支跳转；010：无条件跳转；011：RA。我们采用宏实现。 |
|   PC   |  I   |                          32位老PC值                          |
|  Imm   |  I   |                          26位立即数                          |
|  NPC   |  O   |                         新的PC输出值                         |

### F_IM

| 信号名 | 方向 |     描述     |
| :----: | :--: | :----------: |
|   PC   |  I   | 32位PC输入。 |
| Instr  |  O   | 32位指令输出 |

### FD_reg

| 信号名  | 方向 |      描述      |
| :-----: | :--: | :------------: |
|   clk   |  I   |    时钟信号    |
|  reset  |  I   |  同步复位信号  |
|  D_En   |  I   |    使能信号    |
| F_Instr |  I   | F_IM的读出指令 |
|  F_PC   |  I   |    F级PC值     |
| D_Instr |  O   |  输出D级指令   |
|  D_PC   |  O   |  输出D级PC值   |

### D_GRF

| 信号名 | 方向 |                             描述                             |
| :----: | :--: | :----------------------------------------------------------: |
|  clk   |  I   |                           时钟信号                           |
| reset  |  I   |                         同步复位信号                         |
| W_RFWr |  I   | 写使能信号。由于只有到W级才会进行寄存器堆的写操作，因此该写使能信号来自W级 |
|   A1   |  I   | 5位地址输入信号，指定32个寄存器中的1个，将其中存储的数据读出到RD1 |
|   A2   |  I   | 5位地址输入信号，指定32个寄存器中的1个，将其中存储的数据读出到RD2 |
|   A3   |  I   |  5位地址输入信号，指定32个寄存器中的1个，作为写入目标寄存器  |
|   WD   |  I   |            32位数据输入信号，该数据想写入A3寄存器            |
|  W_PC  |  I   | 用于`display`输出信息。由于只有到W级才会进行寄存器堆的写操作，因此该PC位流水到W级的PC。 |
|  RD1   |  O   |                输出A1指定的寄存器中的32位数据                |
|  RD2   |  O   |                输出A2指定的寄存器中的32位数据                |

GRF的**内部转发**机制：这是流水线最大的改动。GPR 是一个特殊的部件，它既可以视为 D 级的一个部件，**也可以视为 W 级之后的流水线寄存器**。基于这一特性，我们将对 GPR 采用**内部转发**机制。也就是说，当前 GPR 被**写入**的值会**即时**反馈到**读取**端上。

具体的说，当**读**寄存器时的地址与**同周期写**寄存器的地址**相同时**，我们将**读取**的内容改为**写寄存器的内容**，而不是该地址可以索引到的寄存器文件中的值。这里要更GRF的内部逻辑。

### D_EXT

| 信号名  | 方向 |                             描述                             |
| :-----: | :--: | :----------------------------------------------------------: |
|   in    |  I   |                        16位立即数输入                        |
| D_EXTOp |  I   | 立即数扩展功能选择。0：无符号扩展。1：符号扩展。选择何种扩展在D级就已经确定。 |
|   out   |  O   |                         32位扩展结果                         |

### DE_reg

| 信号名  | 方向 |            描述             |
| :-----: | :--: | :-------------------------: |
|  D_PC   |  I   |           D级的PC           |
| D_Imm32 |  I   | D级的经过扩展后的32位立即数 |
| D_Instr |  I   |          D级的指令          |
|  D_RD1  |  I   |        D级的GPR[rs]         |
|  D_RD2  |  I   |        D级的GPR[rt]         |
|  E_PC   |  O   |        输出给E级的PC        |
| E_Imm32 |  O   |    输出给E级的32位立即数    |
| E_Instr |  O   |       输出给E级的指令       |
|  E_RD1  |  O   |       输出给E级的RD1        |
|  E_RD2  |  O   |       输出给E级的RD2        |

### E_ALU

| 信号名  | 方向 |                             描述                             |
| :-----: | :--: | :----------------------------------------------------------: |
| E_ALUOp |  I   | **3位**功能选择信号。 **000**：add。**001**：sub。**010**：ori。**011**：lui |
|   Op1   |  I   |                        32位数据输入1                         |
|   Op2   |  I   |                        32位数据输入2                         |
| result  |  O   |                         32位结果输出                         |

### EM_reg

|   信号名    | 方向 |               描述                |
| :---------: | :--: | :-------------------------------: |
|     clk     |  I   |             时钟信号              |
|    reset    |  I   | 异步复位信号。复位值为 0x00000000 |
|    E_PC     |  I   |              E级PC值              |
| E_ALUResult |  I   |            E级ALU输出             |
|   E_Instr   |  I   |              E级指令              |
|    M_PC     |  O   |              M级PC值              |
| M_ALUResult |  O   |            M级ALU输出             |
|   M_Instr   |  O   |              M级指令              |

### M_DM

| 信号名 | 方向 |                描述                 |
| :----: | :--: | :---------------------------------: |
|  clk   |  I   |              时钟信号               |
| reset  |  I   |  同步复位信号。复位值为 0x00000000  |
|   A    |  I   |            32位地址输入             |
|   WD   |  I   |            32位写入数据             |
| M_DMWr |  I   | 写使能端，当为1时，从输入端存入数据 |
|  M_PC  |  I   |                M级PC                |
|   RD   |  O   |            32位数据输出             |

### MW_reg

| 信号名  | 方向 |               描述                |
| :-----: | :--: | :-------------------------------: |
|   clk   |  I   |             时钟信号              |
|  reset  |  I   | 异步复位信号。复位值为 0x00000000 |
|  M_PC   |  I   |              M级PC值              |
| M_Instr |  I   |              M级指令              |
|  W_PC   |  O   |              W级PC值              |
| W_Instr |  O   |              W级指令              |

### control

| 信号名  | 方向 |             描述              |
| :-----: | :--: | :---------------------------: |
| opcode  |  I   |        `Instr[31:26]`         |
|  funct  |  I   |         `Instr[5:0]`          |
|  Zero   |  I   |      `beq` 条件跳转条件       |
|  NPCOp  |  O   | NPC的取值：`Br` 、`Jal`、`Jr` |
| A3WRSel |  O   |      GRF写地址的选择信号      |
|  WDSel  |  O   |      GRF写入数据选择信号      |
|  RFWr   |  O   |           GRF写使能           |
|  EXTOp  |  O   |         扩展选择信号          |
| ALUBSel |  O   |  ALU第二个输入数据的选择信号  |
|  DMWr   |  O   |           DM写使能            |

## AT法转发/暂停综合分析

### 基本概念

A指的是地址，必须需求数据的部件和供给数据的部件马上要存的地址二者相等时，才考虑转发或暂停。

T指的是 `Tuse` 和 `Tnew` 。

`Tuse`是一个固定值，且一条指令可能有两个。表示某条指令位于 D 级的时候，再经过多少个时钟周期就**必须要使用**相应的数据。例如，对于 `beq` 指令，立刻就要使用数据，因为`Zero`提前了，在D级就需要进行`GPR[rs]`和`GPR[rt]`比较，因此 `Tuse` 为0。这里我们通过GRF的内部转发实现。对于 `add` 指令，等待下一个时钟周期它进入 E 级才要**使用**数据，所以 `Tuse = 1`。而对于 `sw` 指令，在 E 级它需要 `GPR[rs]` 的数据来计算地址(因为`GPR[rd]` 基地址加上扩张后的立即数偏移量)，在 M 级需要 `GPR[rt]` 来存入值，所以 `Tuse_rs = 1 `，`Tuse_rt = 2`。

`Tnew`是一个变化值，且一条指令在一级只有一个`Tnew`，因为一个指令至多写一个寄存器。`Tnew`为位于**某个流水级**的**某个指令**，它经过多少个时钟周期可以**算出结果并**且**存储到流水级寄存器**里。例如，对于 `add` 指令，当它处于 E 级，此时结果还没有存储到流水级寄存器里，所以此时它的 `Tnew = 1`，而当它处于 M 或者 W 级，此时结果已经写入了流水级寄存器，所以此时 `Tnew_m = Tnew_w =0`。

- 当 `Tuse >= Tnew` ，说明需要的数据可以及时算出，可以通过**转发**来解决。
- 当 `Tuse < Tnew` ，说明需要的数据不能及时算出，必须**暂停**流水线解决。

需要注意的是：

- **`Tnew` 从E级才开始分析**。因为 **`Tnew`**（目标数据生成的时钟周期）代表的是寄存器目标值的**生成时刻**，而寄存器值的生成通常是从执行阶段（E级）或之后的阶段开始的。在译码阶段（D级），寄存器的值并不会更新，因此没有必要在D级分析 `Tnew`。

- 因此，可以说，**M 级和 W 级才是转发数据的来源地，而 E 级和 D 级是接收转发地**。
- **什么需要转发？只有指令的源寄存器才需要转发。**存寄存器在这一步不考虑！

### 分析与构造

指令之间的排列组合非常重要。指令的排列顺序决定了如何进行转发或暂停的处理。首先，我们使用 AT 表明确**各级中那些指令组合**下必须需要**暂停**。

要明确 AT 表是什么构造。

- 纵坐标的指令都要记录**源寄存器**。因为纵坐标考虑的是**接收转发**，是害怕这个源寄存器里边需要使用的数据还没给传过来。
- 横坐标记录的是要存入的数据。这些数据存入GRF之后，很可能接下来的指令要用到这些新的数据。因此，要记录有回写功能的指令的 `Tnew`。

![image-20241127174633180](E:\myFolder_3\COLab\P6\assets\image-20241127174633180.png)

我们首先根据这个表实现一下**暂停**逻辑。暂停全部在 D 级，只要 `rs_Stall` 或 `rt_Stall` 有一个为高，那么D级就要暂停，F级就要冻结（冻结进行下一条PC），E级就要冲刷。这三者是同时进行，缺一不可。

下面我们根据上述表实现代码。首先找到左侧所有的 `rt` 。然后对于右侧所有需要暂停的指令，与起来。同时写入端口与需要端口必须相同。且为了提高效率， `rt` 要不为0，因为0寄存器永远无法写入。

因此，是**4个东西与起来**。

实现的时候千万别粗心看差了。有几个细节特别容易看错：

- `rs` 中基本都是 `E_rt` ，但是唯有 `E_Rcal` 的时候是 `E_rd` ！！！
- `rs` 中唯一的 M 级需要暂停的指令 `M_rt` ，是 `M_rt` ！！！别写顺手了搞成 `E_rt` 了！！
- `rt` 中同样注意有上面两个易错点！！！

```verilog
//stall logic
    assign rs_Stall = (E_Rcal && (D_rs == E_rd) && D_rs && (D_Tuse_rs < E_Tnew)) || //E_level
                      (!E_Rcal && (D_rs == E_rt) && D_rs && (D_Tuse_rs < E_Tnew)) ||
                      ((D_rs == M_rt) && D_rs && (D_Tuse_rs < M_Tnew));             //M_level

    assign rt_Stall = (E_Rcal && (D_rt == E_rd) && D_rt && (D_Tuse_rt < E_Tnew)) || //E_level
                      (!E_Rcal && (D_rt == E_rt) && D_rt && (D_Tuse_rt < E_Tnew)) ||
                      ((D_rt == M_rt) && D_rt && (D_Tuse_rt < M_Tnew));             //M_level
```

 除了图中红色标出的组合必须要**暂停**外，其他条件都可以**转发**解决。下面我们要列出**转发与对应的接受关系**表。

我们列出下列表格。进行分析构造：

- D、E 级是接收数据的流水级。其中需要数据的源寄存器和对应的指令已经列出。E、M、W 级是需要转发的数据来源（W级相当于直接回写）。依次是优先级降低的顺序，因为越靠近 ALU 数据优先级越高。
- 每一行从指令开始依次向右看去。按照优先级顺序展开 MUX。 

![image-20241127174610989](E:\myFolder_3\COLab\P6\assets\image-20241127174610989.png)

下面我们根据这个表来实现转发的实现。基本方式就是在 D 级和 E 级分别添加两个专门控制数据冒险的多路选择器。有如下注意事项：

- D 级不需要接受来自 W 级的转发。因为GRF实现内部转发。

```verilog
//forward MUX
    assign D_Sel_rs = (M_Rcal && (D_rs == M_rd) && (D_rs != 0)) || (M_Ical && (D_rs == M_rt) && (D_rs != 0)) ? 2'b01 : 2'b00;
    assign D_Sel_rt = (M_Rcal && (D_rt == M_rd) && (D_rt != 0)) || (M_Ical && (D_rt == M_rt) && (D_rt != 0)) ? 2'b01 : 2'b00;
    assign E_Sel_rs = (M_Rcal && (E_rs == M_rd) && (E_rs != 0)) || (M_Ical && (E_rs == M_rt) && (E_rs != 0)) ? 2'b10 :
                      ((W_lw || W_Ical) && (E_rs == W_rt) && (E_rs != 0)) || (W_Rcal && (E_rs == W_rd) && (E_rs != 0)) ? 2'b01 :
                                                                                                                         2'b00;
    assign E_Sel_rt = (M_Rcal && (E_rt == M_rd) && (E_rt != 0)) || (M_Ical && (E_rt == M_rt) && (E_rt != 0)) ? 2'b10 :
                      ((W_lw || W_Ical) && (E_rt == W_rt) && (E_rt != 0)) || (W_Rcal && (E_rt == W_rd) && (E_rt != 0)) ? 2'b01 :
                                                                                                                         2'b00;
```

在此基础上，我们集成设计一个新的模块——冒险控制单元。

### `hazardUnit` 构造与实现

|  信号名  | 方向 |   描述   |
| :------: | :--: | :------: |
| D_Instr  |  I   | 字面意思 |
| E_Instr  |  I   | 字面意思 |
| M_Instr  |  I   | 字面意思 |
| W_Instr  |  I   | 字面意思 |
| F_Stall  |  O   | 字面意思 |
| D_Stall  |  O   | 字面意思 |
| E_Flush  |  O   | 字面意思 |
| D_Sel_rs |  O   | 字面意思 |
| D_Sel_rt |  O   | 字面意思 |
| E_Sel-rs |  O   | 字面意思 |
| E_Sel_rt |  O   | 字面意思 |

## 思考题汇总

1. 我们使用提前分支判断的方法尽早产生结果来减少因不确定而带来的开销，但实际上这种方法并非总能提高效率，请从流水线冒险的角度思考其原因并给出一个指令序列的例子。
2. 因为延迟槽的存在，对于 jal 等需要将指令地址写入寄存器的指令，要写回 PC + 8，请思考为什么这样设计？
3. 我们要求所有转发数据都来源于流水寄存器而不能是功能部件（如 DM、ALU），请思考为什么？
4. 我们为什么要使用 GPR 内部转发？该如何实现？
5. 我们转发时数据的需求者和供给者可能来源于哪些位置？共有哪些转发数据通路？
6. 在课上测试时，我们需要你现场实现新的指令，对于这些新的指令，你可能需要在原有的数据通路上做哪些扩展或修改？提示：你可以对指令进行分类，思考每一类指令可能修改或扩展哪些位置。
7. 简要描述你的译码器架构，并思考该架构的优势以及不足。

**答**：

1. 问题在于数据冒险导致**暂停**。根据上文表格可知，`beq` 指令有5种情况都需要暂停，非常多。如果一直处于数据冒险的境态之中，那么提前分支判断的机制也没有用武之地。可以说，**控制冒险受制于数据冒险**。**数据冒险**才是 “硬伤” 和对效率起决定性意义的。例如如下指令序列：

```
ori $1, $1, 1
add $2, $0, $1
beq $2, $1, label
......
label:
......
```

执行到 `beq` 时，首先要**暂停**一个周期。然后接收来自 M级的转发，获取最新的寄存器结果。这与不提前进行分支判断，而是再进行一个周期到E级再进行判断，从效率（完成的周期数）上是完全一致的，因为M级也有向E级的转发。

2. 因为**延迟槽**的存在。`PC(jal) + 4` 的指令充当延迟槽，进入流水线且执行，`jal` 要写入31号寄存器的返回地址应该是延迟槽的下一条指令。因此是PC + 8。
3. 主要有三方面考虑：
   - 功能部件（如ALU、DM）的输出通常在时钟周期**内部**的某个时间点才会稳定下来。在时钟周期内，功能部件的输出可能会随着输入的变化而变化，直到计算完成。这意味着，如果直接从功能部件获取数据，前递的数据可能在时钟周期内并不稳定，无法保证在需要使用的阶段提供正确的数据。**流水寄存器在时钟上升沿或下降沿采样输入数据**，并在**整个时钟周期内**保持**数据稳定**。
   -  如果前递数据直接来自功能部件，需要对整个**组合逻辑**路径进行严格的**时序**分析，增加了设计和验证的复杂性。
   - 便于模块化设计、复杂度降低和工程可扩展性。

4. 本质上就是取代**W级向D级的转发**。实现方法：

```verilog
    //read, inside transmission
    assign RD1 = (W_RFWr && A1 == A3 && A3 != 0) ? WD : rf[A1];
    assign RD2 = (W_RFWr && A2 == A3 && A3 != 0) ? WD : rf[A2];
```

5. 详见上文“AT法综合分析”的两张表格。
6. 首先分析该指令的 `Tuse` 和各级的 `Tnew` 。然后可以归结为以下几种类型：
   - R型计算指令，存在`rd`
   - I型计算指令，存在`rt` 
   - 条件跳转指令
   - 无条件跳转指令
   - `load` 类指令
   - `store` 类指令

然后M W两级分别向D E两级转发。特别地对于类似于`jal` 这样的无条件跳转指令，E级也需要向D级转发（往后每一级都要无脑转发PC）。

7. 采用**分布式译码**、**控制信号驱动型**。

```verilog
`timescale 1ns / 1ps

`include "def.v"

module control(
    input [5:0] opcode,
    input [5:0] funct,
	input Zero,
    output [2:0] NPCOp,
    output [2:0] ALUOp,
    output [1:0] A3WRSel,
    output [1:0] WDSel,
    output EXTOp,
    output RFWr,
    output ALUBSel,
    output DMWr
    );

    //AND gate
    wire add = (opcode == 6'b000000 && funct == 6'b100000);
    wire sub = (opcode == 6'b000000 && funct == 6'b100010);
    wire ori = (opcode == 6'b001101);
    wire lw = (opcode == 6'b100011);
    wire sw = (opcode == 6'b101011);
    wire beq = (opcode == 6'b000100);
    wire lui = (opcode == 6'b001111);
    wire nop = (opcode == 6'b000000 && funct == 6'b000000);
	 wire jal = (opcode == 6'b000011);
	 wire jr = (opcode == 6'b000000 && funct == 6'b001000);

    //OR gate
    assign NPCOp = (beq && Zero) ? (`Br) : 
						 (jal) ? `Jal :
						 (jr) ? `Jr :
						 2'b00;
    assign ALUOp = (sub || beq) ? 3'b001 :
                    (ori) ? 3'b010 :
                    (lui) ? 3'b011 :
                    3'b000;
    assign A3WRSel = (add || sub) ? 2'b01 : 
							(jal) ? 2'b10 :
							2'b00;
    assign WDSel = (lw) ? 2'b01 : 
						 (jal) ? 2'b10 :
						 2'b00;
    assign EXTOp = (lw || sw || beq) ? 1'b1 : 1'b0;
    assign RFWr = (add || sub || ori || lw || lui || jal) ? 1'b1 : 1'b0;
    assign ALUBSel = (ori || lw || sw || lui) ? 1'b1 : 1'b0;
	 assign DMWr = (sw) ? 1'b1 : 1'b0;

endmodule
```

好处：较为灵活，降低了流水级间传递的信号量，每次译码出要用到的信号即可。

坏处：需要实例化多个控制器，增加了后续流水级的逻辑复杂度。如错添或漏添了某条指令，很难锁定出现错误的位置。

## 课下测试方法

### 手工构造数据

记录一套课下测出bug的数据：

```
.text
		ori $3,$0,1672 
		add $0,$3,$19
		sw $19,1672($0)
		lw $3,1672($0)
		sw $3,1672($0)
```

说明：如果在GRF内部转发时没有考虑`A3 != 0` 的情况，该数据就会报错。

### 自动化测试

构造了一个自动化数据生成的代码：

```python
import random

# 定义支持的指令生成函数
def add(rd, rs, rt):
    return "add $%d, $%d, $%d" % (rd, rs, rt)

def sub(rd, rs, rt):
    return "sub $%d, $%d, $%d" % (rd, rs, rt)

def ori(rt, rs, imm16):
    return "ori $%d, $%d, %d" % (rt, rs, imm16)

def lw(rt, offset, base):
    return "lw $%d, %d($%d)" % (rt, offset, base)

def sw(rt, offset, base):
    return "sw $%d, %d($%d)" % (rt, offset, base)

def beq(rs, rt, label):
    return "beq $%d, $%d, %s" % (rs, rt, label)

def lui(rt, imm16):
    return "lui $%d, %d" % (rt, imm16)

def jal(label):
    return "jal %s" % label

def jr(rs):
    return "jr $%d" % rs

def nop():
    return "nop"

def generate_test_program(filename):
    with open(filename, "w") as f:
        # 初始化寄存器
        f.write(ori(1, 0, 0x0) + "\n")  # $1 = 0
        f.write(ori(2, 0, 0x0) + "\n")  # $2 = 0
        f.write(nop() + "\n")

        # 使用循环生成指令序列
        for i in range(100):  # 外层循环，生成10个块
            f.write("block_%d:\n" % i)
            # 内层循环，生成指令序列
            for j in range(5):  # 每个块中生成5条指令
                rd = random.randint(1, 31)
                rs = random.randint(0, 31)
                rt = random.randint(0, 31)
                imm16 = random.randint(0, 0xFFFF)
                instr_type = random.choice(['add', 'sub', 'ori', 'lw', 'sw', 'beq', 'lui', 'jal', 'jr', 'nop'])
                if instr_type == 'add':
                    f.write(add(rd, rs, rt) + "\n")
                elif instr_type == 'sub':
                    f.write(sub(rd, rs, rt) + "\n")
                elif instr_type == 'ori':
                    f.write(ori(rt, rs, imm16) + "\n")
                elif instr_type == 'lw':
                    offset = random.randint(0, 1024)
                    base = random.randint(0, 31)
                    f.write(lw(rt, offset, base) + "\n")
                elif instr_type == 'sw':
                    offset = random.randint(0, 1024)
                    base = random.randint(0, 31)
                    f.write(sw(rt, offset, base) + "\n")
                elif instr_type == 'beq':
                    label = "block_%d" % ((i + 1) % 10)
                    f.write(beq(rs, rt, label) + "\n")
                elif instr_type == 'lui':
                    f.write(lui(rt, imm16) + "\n")
                elif instr_type == 'jal':
                    label = "subroutine_%d" % random.randint(0, 9)
                    f.write(jal(label) + "\n")
                elif instr_type == 'jr':
                    f.write(jr(rs) + "\n")
                elif instr_type == 'nop':
                    f.write(nop() + "\n")
                else:
                    pass  # 不会发生

            f.write(nop() + "\n")

        # 生成子程序
        for i in range(100):
            f.write("subroutine_%d:\n" % i)
            f.write(add(1, 1, 1) + "\n")
            f.write(sub(2, 2, 2) + "\n")
            f.write(jr(31) + "\n")
            f.write(nop() + "\n")

    print("生成了测试程序：", filename)

# 生成测试程序文件
test_files = ["test_program1.asm", "test_program2.asm", "test_program3.asm"]
for filename in test_files:
    generate_test_program(filename)
```

## 示意图

![c32448a2b970e4fd349666d66ab47d9](E:\myFolder_3\COLab\P6\assets\c32448a2b970e4fd349666d66ab47d9.jpg)

![image-20241201141053551](E:\myFolder_3\COLab\P6\assets\image-20241201141053551.png)

## 课上注意经验

### 计算型指令

按照步骤：

1. 在控制器中添加该指令，更新数据通路。
2. 更新 `InstrSet` 。根据写入的寄存器是 `rd` 还是 `rt` 来判断应该归为 `Rcal` 还是 `Ical` 。写入相应的类别。
3. 更改 ALU 实现逻辑。

注意，不需要更改冲突处理。只需要进行归类即可。

注意对于 `rs` /`rt` 只使用一个的指令，要无脑添加，不能合并到某一类型的计算指令中，而是单独拉出来判断 `Tuse` 和 `Tnew`。 

### 条件跳转指令

通常是：如果在 D 级符合条件，那么 跳转并链接。

1. 在控制器中增加该指令 `opcode`，并且定义满足条件的信号，修改 `NPCOp` 。
2. 修改 E、M、W 三级流水寄存器，增加该信号。该信号要**往下传**！
3. 接下来继续回到控制器修改数据通路。这时候修改 `A3WRSel`、`WDSel` 、`RFWr`。
4. 修改 InstrSet，添加该指令的输出端口。
5. 到冲突处理单元中，添加该指令，并且添加到 `Tuse` 和 `Tnew` 中。**暂停逻辑不用改**，转发逻辑要添加该指令。转发的时候只需要将所有 `jal` 指令的时候或上**该指令与上信号**即可。注意E、M、W 三级流水信号全都要传到冒险单元中！
6. 顶层通路只需要在 `cmp` 处增加新增判断信号的生成逻辑 ，不需要改其他内容。注意记得在**流水寄存器**和**实例化控制器**中增加该信号。

### 访存类指令

通常分为两类：对从 DM 中取出的数做文章；对要存入 GPR 的地址做文章。

#### 第一类

对 `M_DMRD` 进行修改

#### 第二类

对要存入 GPR 的地址做文章。这一类通常更加麻烦一些。

最典型的就是：

- 如果取出的是偶数，那么写入 `$rt` ，否则写入 `$31` 
- `GPR[(memword+GPR[rt]) & 0x1e] = memword`

采取的一般策略是**在 M 级改 A3** （即 `M_GRFWriteAddr`）。

1. 首先在控制器中加入该信号，然后按照 `lw` 一样，依次修改 `WDSel` 、`EXTOp`、`RFWr`、`ALUBsel` 。注意不需要修改 `A3WRSel` ！这个我们后续在顶层mips中修改，防止信号要回传。

2. 在控制器中专门添加一个**输出当前新增指令**的信号。该信号给 M 级。

3. 在**M级**专门定义并实现一个对于该指令的 A3 地址信号，例如 `M_lwrrAddr`。

4. 在顶层mips中的 M 级更新 `M_for_GRFWriteAddr` 的值。可以在 **最上面**命名一个 `M_for_GRFWriteAddr1`。例如 `assign M_for_GRFWriteAddr1 = M_lwrr ? M_lwrrAddr : M_for_GRFWriteAddr;`。

5. 在 W 级流水寄存器中的输入信号改为 `M_for_GRFWriteAddr1` 。

6. 下面更改冲突处理单元。在 `InstrSet` 中加入该信号。并更新`Tuse` 、`Tnew `值。

7. 对于暂停逻辑，要额外添加。例如 ：`(E_lwrr && D_rs && (D_Tuse_rs < E_Tnew))` 。这是由于必须到 M 级才能知道要写的寄存器到底是多少。因此我们不比较寄存器，一旦T条件满足就直接暂停。

8. 对于转发部分，只需要对于 E、M 两级的三个选择信号有 `lw` 的位置上或上该指令即可。	

9. 最后，在mips顶层中把冲突处理单元的输入信号改为 `M_for_GRFWriteAddr1` 。

   























 
