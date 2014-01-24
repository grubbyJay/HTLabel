HTLabel
=======

core text 

这应该算是开山之作吧~~

首先要非常感谢Jonathan Wight，我用到了他里面写的东西，非常棒，下面是他在github上写的工程的的url

https://github.com/schwa/CoreTextToy/tree/develop

好的，言归正传，写个组件得有它具有的结构，只有结构清楚了，组件理解和维护才会比较容易，先声明暂时不会uml，先写个文字版的结构

这里我只做 xxx[haha]xxx 这样的界面展示

1. 首先得有个展示的view，这里我用HTLabel（继承与UIView），它需要的功能点为下面几点

     1.需要外部传NSAttributedString实例类

     2.其次它有根据上面的NSAttributedString实例类获得整个HTLabel的大小

2. 上面已经提到了要传NSAttributedString实例类，这里就专门做了个NSAttributedString生产加工厂供HTLabel使用
     
     这个由于情况各异，需自己生成各种类型的NSAttributedString实例类，原理是 某一段文本的 属性键+属性值+区域

3. 其次我们要把HTLabel上的渲染部分剥离出来，做个渲染类

4. 这第四点也是非常重要的，那就是一些方法的分类
