## 2.0.4
1. 适配crypto-js 2.0.4

## 2.0.3
1. 修复 单次请求数据量过大报 response data exceeds the maximum limit
2. 在DevEco Studio: NEXT Beta1-5.0.3.806, SDK:API12 Release(5.0.0.66)上验证通过

## 2.0.2
1. 修复Transfer-Encoding:chunked响应数据出现冗余数据
2. 修复Transfer-Encoding:chunked响应数据丢失情况
3. 修复Request接口NewBuilder()未继承原始request属性的问题
4. 修复NewBuilder()未继承client导致丢失超时设置

## 2.0.2-rc.1
1. 修复Transfer-Encoding:chunked响应数据出现冗余数据

## 2.0.2-rc.0
1. 修复Transfer-Encoding:chunked响应数据丢失情况
2. 修复Request接口NewBuilder()未继承原始request属性的问题

## 2.0.1
1. 修复chunked响应体的数据一次返回时，出现数据丢失现象
2. 过滤多次块的大小脏数据
3. 修复gZipUtil工具使用pako入参问题

## 2.0.1-rc.9
1. 修复post请求发送body数据包含中文长度不对问题
2. 修复部分post请求返回数据出现尾部"0"情况
3. pako依赖库升级到2.1.0
4. 修复chunked响应体数据null的情况
5. 过滤响应体出现响应头后块的大小脏数据

## 2.0.1-rc.8
1. 修复上传ArrayBuffer过程中字节00都变成20的问题

## 2.0.1-rc.7
1. 修复cancelRequestByTag接口报错问题。

## 2.0.1-rc.6
1. 修复部分https请求返回响应体多出几个字符内容问题。

## 2.0.1-rc.5
1. 修复概率性socket关闭两次问题。

## 2.0.1-rc.4
1. 修复使用CryptoJS.MD5()语法报错问题

## 2.0.1-rc.3
1. 修复请求为gzip压缩机制时，返回数据长度计算错误问题。

## 2.0.1-rc.2
1. 修复当数据量过大时，String.fromCharCode.apply()方法超出调用栈的最大容量而产生崩溃的问题。

## 2.0.1-rc.1
1. 修复post请求时，部分接口响应的result结果为空问题。
2. 新增Logger开关方法setDebugSwitch。

## 2.0.1-rc.0
1. 支持使用系统默认的CA证书进行通信时进行自定义证书校验。

## 2.0.0
1. 修复多个HttpClient对象执行多个请求时，拦截器没有和对象的拦截器进行关联，而导致拦截器调用错乱问题。
2. 修复服务端返回401时，重试20次问题。
3. 修复Cookie日期字符串转化错误问题。

## 2.0.0-rc.9
1. 支持使用系统默认的CA证书进行通信，依赖手机SDK版本更新。

## 2.0.0-rc.8
1. 修改在Request.ts文件中，Builder构造函数的url和client属性赋值方式。

## 2.0.0-rc.7
1. 修复https发送Post和PUT请求失败问题
2. 修复以表单形式形式进行post请求服务端无法通过@RequestParams进解析报文

## 2.0.0-rc.6
1. 修复事件监听DNS监听失败的问题
2. 修复事件监听callStart监听传参问题
3. 支持GZIP返回的数据格式问题
4. 修复设置responseType属性返回格式问题
5. 修改证书锁定功能指纹参数为证书公钥指纹

## 2.0.0-rc.5
1. 修复xts用例
2. 修复设置证书password失效的问题
3. 增加获取rawfile路径下证书的方法

## 2.0.0-rc.4

1. 完善自定义证书校验功能，
2. 增加tls双向证书的key,cert的配置
3. 修复socket通讯中获取端口失败

## 2.0.0-rc.3

1. 完善自定义证书校验功能

## 2.0.0-rc.2

1. 添加自定义证书校验功能

## 2.0.0-rc.0
1. 框架优化采用链式拦截器
2. 支持网络请求在遇到常见的错误之后自动重新发起请求
3. 支持http2协议网络请求
4. 支持二进制文件分片上传
5. 支持自定义DNS解析
6. 支持WebSocket协议请求
7. 网络请求身份认证
8. tls证书校验
9. 支持响应缓存，缓存当前get请求
10. 支持解析请求响应为自定义数据类型
11. 适配DevEco Studio 3.1 Beta1版本
12. 优化API使用方式
13. 适配更新readme中约束与限制的版本号, 并更新CHANGELOG中的版本号
14. ArkTs新语法适配
15. Cache的构造函数由constructor(filePath: string,maxSize: number)变更为constructor(filePath: string,maxSize: number, context: Context)


## 1.0.5

替换API9 beta版本废弃的上传下载接口

## 1.0.4

1. 适配DevEco 3.1.0.100
2. 修复Content-Type设置错误导致请求失败的BUG

## 1.0.3

文件上传增加文件显示名

## 1.0.2

1. stage模型适配
2. API 9适配
3. 修复multipart方式参数合并BUG，修复cookie存储BUG，修复API9文件路径出错BUG

## 1.0.1

1. httpclient集成okio依赖，并添加相关的示例代码

## 1.0.0

1. gradle项目结构转型为hvigor项目结构.
2. 项目代码优化以及添加 readme.en.md



