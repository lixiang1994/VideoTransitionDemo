# VideoTransitionDemo

视频过渡效果演示

### 前言

应项目需求, 实现视频播放并支持从列表到全屏到详情的流程过渡, 并在过渡中保持视频播放状态, 同时横屏视频模式下, 全屏或详情页面时旋转可以自动切换, 返回时顺序跳转.
Demo中完美还原以上需求, 实现方式具有一定参考价值, 但并不一定适用于其他需求, 仅供参考.

### 概述

通过`UIViewController`的`present/dismiss`进行从视频列表到全屏或者详情页的跳转.

通过自定义`present/dismiss`动画实现过渡效果.

总共分为4个页面:
- 视频列表页面
- 视频竖屏全屏页面
- 视频横屏全屏页面
- 视频详情页面 (带评论列表的那种)

跳转分为两种流程:
- 列表 -> 全屏 -> 详情
- 列表 -> 详情 -> 全屏

动画效果均为从原有页面视频位置过渡到目标页面视频位置.

播放器使用的是`AVPlayer`, 通过`AVPlayerLayer`展示视频画面, 全局只有一个播放器和一个对应的`AVPlayerLayer`, 过渡中通过切换`AVPlayerLayer`的所属视图完成效果.

支持`AVPlayerLayer`的`AVLayerVideoGravity`属性切换不同模式的动画效果.

对过渡处理做了简单封装, 以保证未来需求变动增加新页面跳转时可以快速适配.

### 问题记录

#### Q: 横竖屏切换 原有页面显示异常
#### A: 

在原有页面的`viewWillAppear(_:)`中重新设置`view`的`frame`
```
override func viewWillAppear(_ animated: Bool) {
super.viewWillAppear(animated)
// 解决横竖屏切换时 view异常
view.frame = UIScreen.main.bounds
}
```

#### Q: 动画中 `AVPlayerLayer` 无法和`View`的效果同步
#### A: 
重写`UIView`的`layoutSubviews()`方法 获取`bounds.size`的动画对面, 通过`CATransaction`重新设置`Layer`的`frame`属性与`View`的`bounds`同步.
```
override func layoutSubviews() {
super.layoutSubviews()

if let animation = layer.animation(forKey: "bounds.size") {
CATransaction.begin()
CATransaction.setAnimationDuration(animation.duration)
CATransaction.setAnimationTimingFunction(animation.timingFunction)
layer.sublayers?.forEach({ $0.frame = bounds })
CATransaction.commit()
} else {
layer.sublayers?.forEach({ $0.frame = bounds })
}
}
```

#### Q: 切换`AVPlayerLayer`的`videoGravity`属性时 如何与过渡动画一致?
#### A: 
在过渡的动画块中使用`CATransaction`为`videoGravity`赋值.
```
CATransaction.begin()
CATransaction.setAnimationDuration(duration)
CATransaction.setAnimationTimingFunction(.easeInOut)
playerLayer.videoGravity = self.targetGravity
CATransaction.commit()
```

#### Q: 自定义`present`跳转横屏页面时为何返回后原页面也变成了横屏
#### A: 
目标页面的`modalPresentationStyle`属性要使用`.fullScreen`, 不要使用`.custom`
```
controller.modalPresentationStyle = .fullScreen
```

#### Q: 跳转横屏页面时 原有页面出现布局效果异常的情况
#### A: 
如果使用`AutoLayout`布局, 跳转横屏页面时 `SafeArea`会发生变化, 这会影响到原竖屏页面的布局, 所以这里视频页面布局时不建议使用`SafeArea`, Demo中我使用了[Inch](https://github.com/lixiang1994/Inch)工具来解决适配细节.

### 总结

视频跳转全屏的实现千千万, 但每种方案都有利有弊, 举个例子.

常见的`UIView`直接添加到当前`UIWindow`上然后做视图动画来达到全屏效果, 优点: 方便快捷 实现简单, 缺点: `statusBar`以及全面屏设备的底部横线"`Home`"还处于竖屏状态 并且还要同步处理系统音量视图的旋转等等, 改动范围比较杂, 有些得不偿失的感觉.

还有一种是在原页面中操作视频视图做过渡动画, 动画结束后再通过无动画的`present`切换到目标页面, 这种方法较前者的优点在于利用了`UIViewController`的一些特性, 同时也解决了`statusBar`方向等问题, 但是缺点也是有的, 对应原页面的依赖和影响过于强烈, 因为要在原页面中处理动画等.

最后说说看为何我会选择自定义`present`动画的这种方案, 首先 要说一句真理: 在Apple的平台上搞事情 最好还是按照Apple推荐的方式来做比较稳妥, 不然坑并不会比Apple挖的少, 可以玩骚操作, 但是要能承担得起所带来的问题或者说要负担的起某些责任吧, 说个真实的案例, 也算是一种常见的现象, 很多同类猿 很喜欢探索新的技术, 但是每次都在项目中尝试新技术, 可能是某些大佬的开源框架, 也可能是某些很巧妙的思路或者方案, 但是尝试归尝试, 不要弄得项目中各种技术泛滥, 各种听都没听过的第三方 (可能我见识少 某些几个Star的或者几年不更新的库 确实了解不多), 对于拿公司项目做练手跳板的人 我是真的很鄙视, 自私的无法形容, 根本没有考虑过后来人的感受和对于团队的维护成本, 写个Demo尝试锻炼一下不会死的.

😔 言归正传,  扯远了, 充分利用`UIViewController`的特性并且将处理代码进行封装, 方便后续适配新页面跳转, 不牵扯其他地方的改动, 仅仅是页面跳转而已, 维护成本相对较低.


### 如果你有更好的想法 欢迎Issues留言讨论, 我是LEE, 再见.
