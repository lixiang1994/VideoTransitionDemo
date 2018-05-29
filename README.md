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


