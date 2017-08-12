---
title: Go Runtime 浅析
date: 2017-08-12
tags: Go
comments: true
categories: 技术
author: 彭翌
---

在 GDC Sigma 小组为期两个月的实习已告一段落，本人也十分有幸能在实习期间在团队内部完成了三次 Go 语言相关的分享。由于个人的不足，很遗憾没能向组员分享更多深入的内容，但尽管内容粗浅，这三次分享仍在组内起到了很好的科普作用，收获了组员的一致好评。受组员委托，我将把这三次分享上与 Go 运行时有关的内容整理成文，希望更多的人能从中受益。

本文将完整描述本人在三次组内 Go 分享中提及的与 Go 运行时有关的内容。分享初期关于 Go 语言入门的内容将不在此处赘述。

## Go 运行时概览

阅读 Go 运行时的代码并不如大多数人想象中的那么可怕。实际上，作为与 C/C++ 同级的语言，Go 在很久以前便完成了自举（自己写自己的编译器）的过程，因此当你打开 Go 的 [Github Repository](https://github.com/golang/go) 时你会发现，Go 运行时绝大部分代码由 Go 编写，少部分由汇编语言编写，C/C++ 完全没有。

Go 运行时的核心代码就位于该 Repository 的 [`src/runtime`](https://github.com/golang/go/tree/master/src/runtime) 目录中，包含如下几个主要模块：

- 内存分配（[`malloc.go`](https://github.com/golang/go/blob/master/src/runtime/malloc.go)）
- 垃圾回收（[`mgc.go`](https://github.com/golang/go/blob/master/src/runtime/mgc.go)）
- Goroutine 调度（[`proc.go`](https://github.com/golang/go/blob/master/src/runtime/proc.go)）
- Go 复合类型的实现（[`slice.go`](https://github.com/golang/go/blob/master/src/runtime/slice.go)、[`hashmap.go`](https://github.com/golang/go/blob/master/src/runtime/hashmap.go)、[`chan.go`](https://github.com/golang/go/blob/master/src/runtime/chan.go)、[`error.go`](https://github.com/golang/go/blob/master/src/runtime/error.go)）

总体而言，阅读这些代码时应当不会在语言方面遇到太多的阻力，源文件中也有大量的注释解释每个模块所使用的算法，本文的大多数内容也源自这些注释。但是完全理解这些代码需要读者十分了解操作系统底层的系统调用和优化方法 -- 如果你已经能够熟练使用 C/C++ 开发高性能程序，这些内容对你来说应该不难理解。

接下来我将分模块简单介绍 Go 运行时各个主要模块所采用的算法。

## Goroutine 调度

熟悉 Go 并发编程的人都了解，Go 以 Goroutine 作为执行调度单位，有别于 Python 或 Java 直接使用操作系统线程作为调度单位。在 Goroutine 变长调用栈及用户级调度的共同作用下，一个 Go 程序可以轻易地同时拥有成千上万个 Goroutine 且确保 Goroutine 间的切换不会导致程序的性能下降。本节将以 [Morsing](http://morsmachine.dk/) 的[《The Go scheduler》](http://morsmachine.dk/go-scheduler)一文为基础，简单讲述 Go 语言调度器实现用户级 Goroutine 调度的方式。

首先，Go 调度器主要利用如下 3 种实体进行调度工作：

![](/images/go_runtime_intro_1.jpg)

- 三角形为 [M](https://github.com/golang/go/blob/master/src/runtime/runtime2.go#L383)（Machine），代表一个操作系统线程
- 正方形为 [P](https://github.com/golang/go/blob/master/src/runtime/runtime2.go#L450)（Processor），代表一个操作系统线程要运行 Go 代码时必须用到的资源
- 圆形为 [G](https://github.com/golang/go/blob/master/src/runtime/runtime2.go#L320)（Goroutine），代表一个 Goroutine

众所周知，Go 语言实现的是 M:N 调度，即将 M 个 Goroutine 分配到 N 个操作系统线程上运行，有别于 NodeJS 的 N:1 调度或 Java 的 1:1 调度。在稳定的情况下，M、P、G 间的关系如下：

![](/images/go_runtime_intro_2.jpg)

M 持有一个 P，并利用其中的资源运行 Goroutine；任何时刻，一个 M 上都至多有一个 G 在运行，其他 G 将被放置在 P 的本地队列中等待执行。由正在运行的 G 创建的新 Goroutine 通常会被直接放入对应的本地队列中。

由于 Go 实现的是抢占式的调度，P 在运行某个 G 一段时间后就会将其暂停，放入到本地队列中，并从本地队列中获取另一个 G 执行。

如上描述的是 Goroutine 稳定运行时的状态，有两种情况可以打破这种稳定状态：系统调用及本地队列耗尽。

首先是系统调用：

![](/images/go_runtime_intro_3.jpg)

当正在运行的 G 进行系统调用后，运行该 G 的操作系统线程（M）将进入阻塞态，等待系统调用完成。此时该 M 由于处于阻塞状态，不再运行 Go 代码，因此 Go 调度器会剥夺该 M 所持有的 P 并分配给另一个 M，由新的 M 负责继续运行其他 Goroutine。

当处于阻塞状态的 M 和 G 完成系统调用后，该 G 会被放入到全局等待队列中，M 也会被放入到线程池中，等待调度器再次使用。每个 P 在对正在运行的 G 进行抢占时会不时地检查全局等待队列中是否有已可运行的 G，以避免处于全局等待队列中的 G 发生饥饿现象。

当某个 P 耗尽自己的本地队列后，它会从其他 P 的本地队列中窃取大约一半的 G，以实现负载均衡：

![](/images/go_runtime_intro_4.jpg)

## Go 内存分配

Go 运行时的内存分配算法主要源自 Google 为 C 语言开发的 [TCMalloc](http://goog-perftools.sourceforge.net/doc/tcmalloc.html) 算法，全称 Thread-Caching Malloc。该算法的特色在于其将可用的堆内存采用二级分配的形式进行管理：每个线程都会自行维护一个独立的内存池，进行内存分配时优先从该内存池中分配，当内存池不足时才向全局内存池申请，以避免不同线程对全局内存池的频繁竞争。除此以外，该算法会对小对象和大对象采用不同的内存分配过程。

Go 运行时的内存分配算法在很大程度上与该算法保持一致。首先，Go 在为小对象（大小小于 32 KB）分配内存时会对对象的实际大小向上取整，将对象分类到大约 70 个不同大小的 Size Class 中，并按照 Size Class 的大小为对象分配空间。每个 Size Class 的具体数值系考虑各项约束后自动生成，最小的 Size Class 为 8B，最大为 32KB。详见 [`mksizeclasses.go`](https://github.com/golang/go/blob/master/src/runtime/mksizeclasses.go) 和 [`sizeclasses.go`](https://github.com/golang/go/blob/master/src/runtime/sizeclasses.go)。

在明确这一概念后，我们便可以开始了解 Go 内存分配算法主要使用的数据结构了：

- [`mheap`](https://github.com/golang/go/blob/master/src/runtime/mheap.go)：代表 Go 程序所持有的所有堆空间，可视为由若干个大小为 8 KB 的内存页组成的数组
- [`mspan`](https://github.com/golang/go/blob/master/src/runtime/mheap.go#L214)：一个 `mspan` 从属于某个指定的 Size Class，在 `mheap` 上占据若干个连续的内存页，其内部根据所属 Size Class 的大小被平均划分为若干个 object。每个 `mspan` 会使用一个 bitmap 来标记其内部尚可用的 object
- [`mcache`](https://github.com/golang/go/blob/master/src/runtime/mcache.go)：Goroutine 本地缓存的可用 `mspan`，是上一节所提到的 `P` 的[一部分](https://github.com/golang/go/blob/master/src/runtime/runtime2.go#L460)
- [`mcentral`](https://github.com/golang/go/blob/master/src/runtime/mcentral.go)：全局可用的 `mspan` 列表。Goroutine 在需要时会从 `mcentral` 获取 `mspan`

如此一来，Go 运行时进行内存分配的过程就十分清晰了。当 Go 需要为小对象分配对象时，小对象会被向上取整至最近的 Size Class，并执行如下步骤：

1. 从当前 `P` 的 `mcache` 中获取属于该 Class 且仍有空闲位置的 `mspan`
2. 若 `mcache` 已空，则从 `mcentral` 获取一整个 `mspan` 到当前 `P` 的 `mcache` 中
3. 若 `mcentral` 已空，则从 `mheap` 中获取若干个连续内存页，构建新的 `mspan` 并放入到 `mcentral` 中
4. 若 `mheap` 已空，则从操作系统申请若干个内存页到 `mheap` 中

对于大对象而言，Go 则会跳过 `mcache` 和 `mcentral`，直接在 `mheap` 上构建一个合适大小的 `mspan` 进行分配

## Go 垃圾回收

在了解了 Go 如何为对象分配内存后，我们便可以开始学习 Go 是如何进行垃圾回收的了。

当前 Go 的最新版本为 1.8.3，Go 采用的是**并发**、**三色**的**标记 - 清除**垃圾收集器。这个垃圾收集器在 Go 1.5 版的时候引入，并在当时将 Go 的 GC Pause 时间缩短到了 1.4 版的[几百分之一](https://talks.golang.org/2015/go-gc.pdf)。尽管做出了不少的修改，Go 的垃圾收集算法参考了 Dijkstra 在 1978 年写的论文：[《On-the-Fly Garbage Collection: An Exercise in Cooperation》](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/12/On-the-fly-Garbage-Collection.pdf)。

标记 - 清除算法可以说是最经典的垃圾回收算法。该算法的回收过程分为两个步骤：

1. 标记：从 GC Root 对象开始，沿着对象中包含的所有指针递归地标记所有可达的对象。GC Root 对象包括所有在标记前便确定可达的对象，如全局变量、位于栈帧中的本地变量等
2. 清除：在标记阶段结束后，未被标记的对象意味着不可达。清除阶段将清除所有未被标记的对象，释放它们所占用的内存。

标记 - 清除算法作为最经典也是最基础的算法存在着它的不足，最主要的不足在于它在清除阶段会对未被标记的对象原地进行释放，被释放对象所留下的空隙便形成了内存碎片，而内存碎片的存在会导致程序的内存空间利用率下降。

实际上，Go 所谓的并发、三色的标记 - 清除垃圾收集算法并不新鲜，JVM 和 V8 中都有类似的收集算法。在 JVM 中，该收集器被称为 CMS 收集器（Concurrent Mark-Sweep）。JVM 的 CMS 收集器执行过程与 Go 的收集器类似，也有着和 Go 的收集器相似的特性：以降低程序计算吞吐量为代价，减少 GC Pause 的时间。

Go 垃圾收集器的一次收集过程可归纳为如下几个步骤：

1. `_GcOff`：两次 GC 间，Go 程序将处于 `_GcOff` 状态。GC 发生的过程中会把所有处于 `mcache` 中的 `mspan` 放回 `mcentral`，以让 Goroutine 申请内存时需要重新从 `mcentral` 获取 `mspan`。Goroutine 获取 `mspan` 时会 lazy 地清除 `mspan` 中在上一次 GC 中未被标记的对象。除此以外，另一个 GC Bg Worker Goroutine 也会主动地清扫未被清扫地 `mspan`；
2. 清除终止：开始 GC 前的准备工作。此时程序会 Stop the world，并清扫所有仍未被清扫的 `mspan`。通常 GC 会在程序的内存占用达到一定阈值时被触发，通常此时应当已经不存在仍未被清扫的 `mspan`。若此次 GC 是由 `runtime.GC()` 等方式手动触发的则情况可能有所不同；
3. `_GcMark`：标记阶段。此时 Go 收集器会利用之前开启的 Stop the world，为所有用户 Goroutine 启动写屏障（Write Barrier）。然后，Go 收集器会把 GC Root 对象的标记工作放入到标记作业队列（置为**灰色**）。之后 Go 收集器便会恢复用户 Goroutine 的执行。开启了写屏障的 Goroutine 在每次修改指针变量的值时会使得新旧指针指向的对象均被置为灰色，而新创建的对象这会直接被置为**黑色**（已标记）。除此以外，位于后台运行的 Mark Worker Goroutine 会开始从标记作业队列中获取颜色为灰色的对象，对其进行标记（置为黑色），并将其指向的其他结点置为灰色（放入标记作业队列），直到作业队列被耗尽；
4. `_GcMarkTermination`：标记阶段的收尾工作。Stop the world，并完成队列中剩余的标记作业。通常此时队列已为空。完成标记作业后将继续完成其他 GC 收尾工作，如将 Goroutine `mcache` 中的 `mspan` 放回到 `mcentral`；
5. `_GcOff`：GC 结束，恢复用户 Goroutine 的执行，由用户 Goroutine 和 GC Worker Goroutine 对 `mspan` 中未被标记的对象进行回收

下图显示了 Go 垃圾回收的大致过程：

![](/images/go_runtime_intro_5.png)

比较无奈的是，Go 现在所采用的垃圾回收算法存在着一定的不足。原因主要在于 Go 没有对堆中的对象进行分代，每次 GC 发生时都需要对堆中的所有对象进行标记工作，因此标记的工作量将与堆的大小呈线性相关。Go 的垃圾回收算法的目标是降低 GC Pause 时间，但需要做的工作并不会因为 GC Pause 变短而消失不见，因此在这种情况下，Go 的 GC Bg Mark Worker 可能会占用不少的计算资源来完成全堆的标记工作。详见这个由 Uber 给出的 [Go GC 展示](https://www.youtube.com/watch?v=q1h2g84EX1M)。

## 结语

以上便是我在组内进行 Go 分享时介绍的有关 Go 运行时的全部内容。未来如果有机会能够继续深入学习这一块的内容，我也会把最新的收获发布在博客中，敬请期待。
