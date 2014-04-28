[quick-cocos2d-x]Physics Editor Exporter
=========================================

本项目基于[quick-cocos2d-x](https://github.com/dualface/quick-cocos2d-x)引擎的physics editor exporter做了一些修改：

1.  模板中的将要导出的fixture字段修改为更适合Chipmunk引擎的shape字段

2.  修正了多边形定点按照scaleFactor计算的bug

说明：sample例子基于quick-cocos2d-x 2.2.1rc版本