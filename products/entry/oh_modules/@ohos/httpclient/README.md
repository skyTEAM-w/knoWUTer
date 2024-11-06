

## httpclient

## 简介

HTTP是现代应用程序通过网络交换数据和媒体的的主要方式。httpclient是OpenHarmony 里一个高效执行的HTTP客户端，使用它可使您的内容加载更快，并节省您的流量。httpclient以人们耳熟能详的OKHTTP为基础，整合android-async-http，AutobahnAndroid，OkGo等库的功能特性，致力于在OpenHarmony 打造一款高效易用，功能全面的网络请求库。当前版本的httpclient依托系统提供的网络请求能力和上传下载能力，在此基础上进行拓展开发，已经实现的功能特性如下所示：

1.支持全局配置调试开关，超时时间，公共请求头和请求参数等，支持链式调用。

2.自定义任务调度器维护任务队列处理同步/异步请求。

3.支持tag取消请求。

4.支持设置自定义拦截器。

5.支持重定向。

6.支持客户端解压缩。

7.支持文件上传下载。

8.支持cookie管理。

9.支持对请求内容加解密。

10.支持自定义请求。

11.支持身份认证。

12.支持证书校验。

13.支持响应缓存。

14.支持请求配置responseData属性。

15.支持设置请求优先级。

16.支持证书锁定。

## 下载安装

```javascript
ohpm install @ohos/httpclient
```

OpenHarmony ohpm环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md)



## 使用说明

API使用方式变更(原有的httpclient已废弃 )，新的使用方式请参照以下的使用说明。

```
 在entry的module.json5中添加网络请求权限
 "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.GET_NETWORK_INFO"
      }
    ]
```

```
import { HttpClient,TimeUnit } from '@ohos/httpclient';
```

获取HttpClient对象并配置超时时间

```javascript
this.client =new HttpClient.Builder()
    .setConnectTimeout(10, TimeUnit.SECONDS)
    .setReadTimeout(10, TimeUnit.SECONDS)
    .setWriteTimeout(10, TimeUnit.SECONDS)
    .build();

let status :string= '' // 响应码
let content:string= '' // 响应内容
```

### GET请求方法示例

  ```javascript
import { HttpClient, Request,Logger } from '@ohos/httpclient';

// 配置请求参数
let request = new Request.Builder()
              .get("https://postman-echo.com/get?foo1=bar1&foo2=bar2")
              .addHeader("Content-Type", "application/json")
              .params("testKey1", "testValue1")
              .params("testKey2", "testValue2")
              .build();
  // 发起请求
  this.client.newCall(request).enqueue((result) => {
              if (result) {
                  this.status = result.responseCode.toString();
              }
              if (result.result) {
                this.content = result.result;
              } else {
                this.content = JSON.stringify(result);
              }
              Logger.info("onComplete -> Status : " + this.status);
              Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
            }, (error)=> {
              this.status = error.code.toString();
              this.content = error.data;
              Logger.info("onError -> Error : " + this.content);
            });
          }) 
  ```

### POST请求方法示例 

```javascript
import { HttpClient, Request,RequestBody,Logger } from '@ohos/httpclient';

 let request: Request = new Request.Builder()
            .url("https://1.94.37.200:8080/user/requestBodyPost")
            .post(RequestBody.create(
                {
                    "email": "zhang_san@gmail.com",
                    "name": "zhang_san"
                }
                ,new Mime.Builder().contentType('application/json').build().getMime()))
            .ca([this.certData])
            .build();

 this.client.newCall(request).execute().then((result) => {
              if (result) {
                this.status = result.responseCode.toString();
              }
              if (result.result) {
                this.content = result.result;
              } else {
                this.content = JSON.stringify(result);
              }
              Logger.info("onComplete -> Status : " + this.status);
              Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
            }).catch((error)=> {
              this.status = error.code.toString();
              this.content = error.data;
              Logger.error("onError -> Error : " + this.content);
            });
        })
```

### POST请求方法带两个参数示例

  ```javascript
import { HttpClient, Request,RequestBody,Mime,Logger } from '@ohos/httpclient';  

let request = new Request.Builder()
              .url("https://postman-echo.com/post")
              .post(RequestBody.create({
                a: 'a1', b: 'b1'
              }, new Mime.Builder()
              .contentType('application/json', 'charset', 'utf8').build().getMime()))
              .build();
// 发起同步请求
  this.client.newCall(request).execute().then((result) => {
              if (result) {
                this.status = result.responseCode.toString();;
              }
              if (result.result) {
                this.content = result.result;
              } else {
                this.content = JSON.stringify(result);
              }
              Logger.info("onComplete -> Status : " + this.status);
              Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
            }).catch((error)=> {
              this.status = error.code.toString();
              this.content = error.data;
              Logger.error("onError -> Error : " + this.content);
            });
  ```

### POST请求方法使用FormEncoder示例

  ```javascript
    import { HttpClient, Request,FormEncoder,Logger } from '@ohos/httpclient';
    
    let formEncoder = new FormEncoder.Builder()
        .add("email","zhang_san@gmail.com")
        .add("name","zhang_san")
        .build();
    let feBody = formEncoder.createRequestBody();
    let request: Request = new Request.Builder()
        .url("https://1.94.37.200:8080/user/requestParamPost")
            // 发送表单请求的时候，请配置header的Content-Type值为application/x-www-form-urlencoded
        .addHeader("Content-Type","application/x-www-form-urlencoded") 
        .post(feBody)
        .ca([this.certData])
        .build();
    
      this.client.newCall(request).execute().then((result) => {
          if (result) {
            this.status = result.responseCode.toString();
          }
          if (result.result) {
            this.content = result.result;
          } else {
            this.content = JSON.stringify(result);
          }
          Logger.info("onComplete -> Status : " + this.status);
          Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
        }).catch((error)=> {
          this.status = error.code.toString();
          this.content = error.data;
          Logger.error("onError -> Error : " + this.content);
        });
  ```

### PUT请求示例

  ```javascript
import { HttpClient, Request, RequestBody,Logger } from '@ohos/httpclient';

let request: Request = new Request.Builder()
    .url("https://1.94.37.200:8080/user/createUser")
    .put(RequestBody.create(
        {
            "age": 0,
            "createTime": "2024-03-08T06:12:53.876Z",
            "email": "string",
            "gender": 0,
            "mobile": "string",
            "name": "string",
            "updateTime": "2024-03-08T06:12:53.876Z",
            "userUuid": "string"
        }, new Mime.Builder().contentType('application/json').build()))
    .ca([this.certData])
    .build();

 this.client.newCall(request).execute().then((result) => {
              if (result) {
                this.status = result.responseCode.toString();
              }
              if (result.result) {
                this.content = result.result;
              } else {
                this.content = JSON.stringify(result);
              }
              Logger.info("onComplete -> Status : " + this.status);
              Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
            }).catch((error) => {
              this.status = error.code.toString();
              this.content = error.data;
              Logger.error("onError -> Error : " + this.content);
            });
  ```

### DELETE请求示例

  ```javascript
import { HttpClient, Request, RequestBody,Logger } from '@ohos/httpclient'; 

let request = new Request.Builder()
              .url("https://reqres.in/api/users/2")
              .delete()
              .build();

 this.client.newCall(request).execute().then((result) => {
      if (result) {
          this.status = result.responseCode.toString();
      }
      if (result.result) {
           this.content = result.result;
      } else {
           this.content = JSON.stringify(result);
      }
         Logger.info("onComplete -> Status : " + this.status);
         Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
      }).catch((error) => {
         this.status = error.code.toString();
         this.content = error.data;
         Logger.error("onError -> Error : " + this.content);
      });
  ```

### tag取消请求示例

```javascript
import { HttpClient, Request, RequestBody,Logger } from '@ohos/httpclient';  

let request = new Request.Builder()
                  .get()
                  .url(this.echoServer)
                  .tag("tag123") // 给请求设置tag
                  .addHeader("Content-Type", "application/json")
                  .build();

 this.client.newCall(request).enqueue((result) => {
      if (result) {
         this.status = result.responseCode.toString();
      }
      if (result.result)
         this.content = result.result;
       else
         this.content = JSON.stringify(result);
        }, (error) => {
         this.content = JSON.stringify(error);
    });

  this.client.cancelRequestByTag("tag123"); // 通过tag取消请求
```

### 文件上传示例

 获取上传文件的路径 并生成上传文件(此步骤可以省略 上传文件也可通过命令导入设备) ，同时处理上传文件路径

  ```javascript
import { HttpClient, Request, FileUpload,Logger } from '@ohos/httpclient';

    let hereAbilityContext: Context = getContext();
    let hereCacheDir: string = hereAbilityContext.cacheDir;
    let hereFilesDir: string = hereAbilityContext.filesDir;

     const ctx = this
     Logger.info(" cacheDir   " + hereCacheDir)
     let filePath = hereCacheDir + fileName;
     Logger.info("   filePath   " + filePath)
     let fd = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
     fs.truncateSync(fd.fd)
     fs.writeSync(fd.fd, "test httpclient")
     fs.fsyncSync(fd.fd)
     fs.closeSync(fd)

    Logger.info(" writeSync    ");
    Logger.info( "create file success   ")
	
	// 由于文件上传目前仅支持“dataability”和“internal”两种协议类型，
	// 但“internal”仅支持临时目录，示例 internal://cache/path/to/file.txt	          	  
	// 所以需要将拿到的文件路径转化为internal格式的路径
    filePath = filePath.replace(hereCacheDir, "internal://cache");

  ```

开始上传

```javascript
import { HttpClient, Request, FileUpload,Logger } from '@ohos/httpclient';

    let hereAbilityContext: Context = getContext();
    let hereCacheDir: string = hereAbilityContext.cacheDir;
    let hereFilesDir: string = hereAbilityContext.filesDir;
	//生成文件上传对象并包装参数
    let fileUploadBuilder = new FileUpload.Builder()
      .addFile(filePath)
      .addData("name2", "value2")
      .build();

    Log.showInfo('about to set : abilityContext - cacheDir  = ' + hereCacheDir);
    Log.showInfo('about to Set : abilityContext - filesDir  = ' + hereFilesDir);
    Log.showInfo("type of :" + typeof hereAbilityContext)

	// 生成上传参数
    let request = new Request.Builder()
      .url(this.fileServer)
      .body(fileUploadBuilder)
      .setAbilityContext(hereAbilityContext)
      .build();

    this.client.newCall(request).execute().then((data) => {
        // 上传进度回调监听
      data.uploadTask.on('progress', (uploadedSize, totalSize) => {
        Logger.info('progress--->uploadedSize: ' + uploadedSize 
                     + ' ,totalSize--->' + totalSize);
        if (uploadedSize == totalSize){
			 Logger.info("upload success")
        }
      })
        // 上传完毕回调监听
      data.uploadTask.on('headerReceive', (headers) => {
        Logger.info( 'progress--->uploadSize: ' + JSON.stringify(headers));
      })
    }).catch((error)=> {
        this.status = "";
      this.content = error.data;
      Logger.error("onError -> Error : " + this.content);
    });
```

### 文件下载请求示例

  ```javascript
import { HttpClient, Request,Logger } from '@ohos/httpclient';

    let hereAbilityContext: Context = getContext();
    let hereFilesDir: string = hereAbilityContext.filesDir;

try {
      this.status = "";
      let fPath = hereFilesDir + "/sampleEnqueue.jpg";
     
     // request可以不设置下载路径fPath，如果不设置下载路径fPath，下载的文件默认缓存在cache文件夹
      let request = new Request.Builder()
      .download("https://imgkub.com/images/2022/03/09/pexels-francesco-ungaro-15250411.jpg", fPath)
      .setAbilityContext(hereAbilityContext)
      .build();
      // 发起请求
      this.client.newCall(request).enqueue((data) => {
          // 设置下载完成监听
          data.downloadTask.on('complete', () => {
           	Logger.info(" download complete");
           	this.content = "Download Task Completed";
           	});
            // 设置下载进度监听
          data.downloadTask.on("progress", ( receivedSize, totalSize)=>{
          	 Logger.info(" downloadSize : "+receivedSize+" totalSize : "+totalSize);
           	 this.content = ""+(receivedSize/totalSize)*100;
           	});
           }, (error)=> {
                this.status = "";
                this.content = error.data;
                Logger.error("onError -> Error : " + this.content);
              });
            } catch (err) {
              Logger.error(" execution failed - errorMsg : "+err);
            }
  ```

### 二进制文件分片上传示例

导入上传文件至应用cache目录 ，并使用chown命令修改用户权限

    1. 查询应用cache沙箱路径对应的物理路径
    2. 进入此物理路径，修改cache下的文件如uoload.rar的权限为同一个user_id
        2.1 查询user_id 使用： ps -ef | grep cn.openharmony.httpclient 注：替换自己的包名即可,查询结果的第一列即为user_id
    3.使用chown {user_id}:{user_id} uploar.rar  本例： chown 20010042:20010042 upload.rar

[可参考，应用沙箱路径和调试进程视角下的真实物理路径](https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/file-management/send-file-to-app-sandbox.md/)


开始上传

```javascript
  import { HttpClient, Request,BinaryFileChunkUpload,Logger } from '@ohos/httpclient';

    let hereAbilityContext: Context = getContext();
    let hereCacheDir: string = hereAbilityContext.cacheDir;
  
	// 待上传文件路径
    let filePath: string = this.hereCacheDir + '/' + this.fileName
	let fileUploadBuilder = new BinaryFileChunkUpload.Builder()
      .addBinaryFile(hereAbilityContext, {
        filePath: filePath,
        fileName: this.fileName,
        chunkSize: 1024 * 1024 * 4,
        name: 'chunk'
      })
      .addData('filename', this.fileName)
      .addUploadProgress(this.uploadCallback.bind(this))
      .addUploadCallback(this.callStat.bind(this))
      .build();

    let request = new Request.Builder()
    .url(this.baseUrl + '/upload')
    .setAbilityContext(hereAbilityContext)
    .body(fileUploadBuilder)
    .build();

    this.client.newCall(request).execute();
```

### 拦截器使用示例

```javascript
import { Chain, Dns, HttpClient, Interceptor, Request, Response, TimeUnit, Utils,Logger } from '@ohos/httpclient';

// 通过addInterceptor添加拦截器
// addInterceptor允许调用多次，添加多个拦截器，拦截器的调用顺序根据添加顺序来决定
let request = new Request.Builder()
           		.url('https://postman-echo.com/post')
            	.post()
         		.body(RequestBody.create('test123'))
         		.setDefaultConfig(defaultConfigJSON)
         		.addInterceptor(new CustomInterceptor())
           		.build();
           		
   this.client.newCall(request).execute().then((result) => {
              if (result) {
                this.status = result.responseCode.toString();
              }
              if (result.result) {
                this.content = result.result;
              } else {
                this.content = JSON.stringify(result);
              }
              Logger.info("onComplete -> Status : " + this.status);
              Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
            }).catch((error) => {
              this.status = error.code.toString();
              this.content = error.data;
              Logger.error("onError -> Error : " + this.content);
            }); 

```

```javascript
export class CustomInterceptor implements Interceptor {
  intercept(chain: Chain): Promise<Response> {
    return new Promise<Response>(function (resolve, reject) {
      let request = chain.requestI();
      Logger.info("request = " + request)
      let response = chain.proceedI(request)
      Logger.info("response = " + response)
      response.then((data) => {
        resolve(data)
      }).catch((err) => {
        reject(err)
      })
    })
  }
}
```

### gzip解压缩示例

客户端编解码文本

```javascript
import { FileUpload, gZipUtil, HttpClient, Mime, Request, RequestBody } from '@ohos/httpclient'

//编码文本
const test = "hello, GZIP! this is a gzip word";
let compressed = gZipUtil.gZipString(test);
//解码文本
let restored =   gZipUtil.ungZipString(JSON.parse(JSON.stringify(compressed)));
let result = "解码后数据:" + restored

```

客户端编码文件

```javascript
// 编码文件
let appInternalDir: string = this.getContext().cacheDir;
let encodeStr = "hello, GZIP! this is a gzip word"
let resourcePath = appInternalDir + "/hello.txt";
let gzipPath = appInternalDir + "/test.txt.gz";
let fd = fs.openSync(resourcePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
fs.truncateSync(fd.fd);
fs.writeSync(fd.fd, encodeStr);
fs.fsyncSync(fd.fd)
fs.closeSync(fd);
gZipUtil.gZipFile(resourcePath, gzipPath);

```

客户端解码文件

```javascript
// 解压缩字符串
let appInternalDir = getContext().cacheDir;
let gzipPath = appInternalDir + "/test.txt.gz";
let dest = appInternalDir + "/hello2.txt";

await gZipUtil.ungZipFile(gzipPath, dest);

let fileID = fs.openSync(dest, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
// 获取文件信息
let stat = fs.statSync(fileID.fd);
let size = stat.size // 文件的大小，以字节为单位
let buf = new ArrayBuffer(size);
fs.readSync(fileID.fd, buf)
let textDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true });
let decodedString = textDecoder.decode(new Uint8Array(buf), { stream: false });
let result='解压成功'
result = '\n原编码文件路径:' + gzipPath + '\n'
result += '\n解码后路径:' + dest + '\n'
result += '\n文件大小:' + size + ' byte' + '\n'
result += '\n解码结果:' + decodedString + '\n'

```

```javascript
let test = "hello, GZIP! this is a gzip word";
let requestBody: RequestBody = RequestBody.create(test);
let request: Request = new Request.Builder()
    .url('http://www.yourserverfortest.com')
    .post(requestBody)
    // 添加Accept-Encoding请求头，进行gzip压缩
    .addHeader('Accept-Encoding', 'gzip')
    // 添加压缩后传送数据类型
    .addHeader('Content-Type', 'application/octet-stream')
    // 将压缩数据转成buffer对象
    .setGzipBuffer(true)
    .build();

this.client.newCall(request).execute().then((result) => {
    if (result.result) {
        Logger.info('返回结果: ' + result.result);
    } else {
        Logger.info('返回结果: ' + JSON.stringify(result));
    }
}).catch((err) => {
    Logger.error('请求状态: ' + error.code.toString());
})
```

http支持自动解压缩

```javascript
let requestBody1 = RequestBody.create('your data', new Mime.Builder().build().getMime())
let request = new Request.Builder()
    .url('http://www.yourserverfortest.com')
    .post(requestBody1)
    .addHeader("Content-Type", "text/plain")
    .addHeader("Accept-Encoding", "gzip")
    .build();

this.client.newCall(request).enqueue((result) => {
    this.status = '\n返回状态：' + result.responseCode + '\n';
    if (result.result) {
        this.content += '\n返回结果：' + result.result + '\n';
        this.content += '\n返回header：' + JSON.stringify(result.header) + '\n';
    } else {
        this.content += '\n返回结果：' + result.result + '\n';
    }
   
}, (error) => {
    this.status = '请求状态：' + error.code.toString();
    this.content = error.data;
   
});
```

http上传gzip文件

```javascript
let hereCacheDir: string = getContext().cacheDir;

let appInternalDir = hereCacheDir;
let destpath = appInternalDir + "/test2.txt.gz";
destpath = destpath.replace(hereCacheDir, "internal://cache");

let fileUploadBuilder = new FileUpload.Builder()
.addFile(destpath)
.addData("filename", "test2.txt")
.build();
let fileObject = fileUploadBuilder.getFile();
let dataObject = fileUploadBuilder.getData();

let request = new httpclient.Request.Builder()
.url('http://www.yourserverfortest.com')
.addFileParams(fileObject, dataObject)
.setAbilityContext(this.hereAbilityContext)
.build();
this.client.newCall(request).execute().then((data) => {
 data.uploadTask.on('progress', (uploadedSize, totalSize) => {
     Logger.info('Upload progress--->uploadedSize: ' + uploadedSize + ' ,totalSize--->' + totalSize);
     this.content = "当前上传大小：" + uploadedSize + 'byte\n'
     if (uploadedSize >= totalSize) {
         Logger.info('Upload finished');
         this.content += "\n上传总文件大小：" + totalSize + 'byte\n'
         this.content += "\n上传文件路径：" + appInternalDir + "/test2.txt.gz\n"
     }
 })
 data.uploadTask.on('headerReceive', (headers) => {
     Logger.info('Upload--->headerReceive: ' + JSON.stringify(headers));
 })
 data.uploadTask.on('complete', (data) => {
     this.status = "上传完成"
     this.status += "\n上传结果：" + data[0].message
     Logger.info('Upload--->complete,data: ' + JSON.stringify(data));
 })
}).catch((error) => {
 this.status = "";
 this.content = error;
 Logger.error("onError -> Error : " + this.content);
});
```

http下载gzip文件

```javascript
let hereAbilityContext: Context = getContext();
let hereFilesDir: string = this.hereAbilityContext.filesDir;

this.downloadfile = this.hereFilesDir + '/yourserverUrlFileName';
let request = new Request.Builder()
    .download('http://www.yourserverfortest.com/yourserverUrlFileName')
    .setAbilityContext(this.hereAbilityContext)
    .build();
this.client.newCall(request).execute().then(async (data) => {
    data.downloadTask.on('progress', (receivedSize, totalSize) => {
        this.content = '\n下载文件大小:' + receivedSize + ' byte\n'
        this.content += '\n下载文件总大小:' + totalSize + ' byte\n'
        this.content += "\n下载文件路径：" + this.downloadfile + '\n'
    })
    data.downloadTask.on('complete', async () => {
        let appInternalDir = this.hereFilesDir;
        let dest = appInternalDir + "/helloServer.txt";
        await gZipUtil.ungZipFile(this.downloadfile, dest);
        let fileID = fs.openSync(dest, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        // 获取文件信息
        let stat = fs.statSync(fileID.fd);
        let size = stat.size // 文件的大小，以字节为单位
        let buf = new ArrayBuffer(size);
        fs.readSync(fileID.fd, buf)
        let textDecoder = new util.TextDecoder("utf-8", { ignoreBOM: true });
        let decodedString = textDecoder.decode(new Uint8Array(buf), { stream: false });
        this.status = '下载成功'
        this.content += '\n下载文件内容:' + decodedString + '\n'
    })
}).catch((error) => {
    this.status = '请求状态：' + error.code.toString();
    this.content = error.data;
    Logger.error("onError -> Error : " + JSON.stringify(error));
});

```

### cookie管理示例

初始化

```javascript
import {CookieJar,CookieManager,CookiePolicy,CookieStore,HttpClient,Request,RequestBody,
  TimeUnit,Logger} from '@ohos/httpclient';
  let hereCacheDir: string = getContext().cacheDir;
  client: any = new HttpClient
    .Builder()
    .setConnectTimeout(10, TimeUnit.SECONDS)
    .setReadTimeout(10, TimeUnit.SECONDS)
    .build();
  cookieJar = new CookieJar();
  cookieManager = new CookieManager();
  store = new CookieStore(hereCacheDir);


```

给httpclient设置cookie管理的参数

```javascript
  Logger.info("http cookiejarRequest request sending ");

  this.cookiemanager.setCookiePolicy(httpclient.CookiePolicy.ACCEPT_ALL);// 设置缓存策略
  this.cookiejar.setCookieStore(this.store); // 设置cookie存取处理对象

  //first request to get the cookie
  let request1 = new Request.Builder()
        .get(this.commonServer) //Modify URL
        .tag("tag_cookie1")
        .cookieJar(this.cookiejar) // 给httpclient设置缓存处理对象
        .cookieManager(this.cookiemanager) // 给httpclient设置缓存策略管理对象
        .addHeader("Content-Type", "application/json")
        .build();

   this.client.newCall(request1).enqueue(this.onComplete, this.onError);
```

//  设置httpclient请求回调

```javascript
    onComplete: function (result) {
        if (result.response) {
            this.status = result.response.responseCode;
        }
        if (result.response.result)
            this.content = result.response.result;
        else
            this.content = JSON.stringify(result.response);

        Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
    },
    onError: function (error) {
        Logger.error("onError -> Error : " + error);
        this.content = JSON.stringify(error);
        Logger.error("onError -> Content : " + JSON.stringify(this.content));
    },
```

### 请求内容加解密示例

导入加密库crypto-js

```json
	"dependencies": {
		"@ohos/crypto-js": "^1.0.2"
	}
```

引入加密模块

```typescript
import { CryptoJS } from '@ohos/crypto-js'

const secretKey: string = 'abcd1234' 
```

使用AES加密请求内容，解密响应结果
```typescript
import {HttpClient,Request,RequestBody,TimeUnit,Logger} from '@ohos/httpclient';

let request = new Request.Builder()
     .post()
     .body(RequestBody.create("test123"))
     .url(this.echoServer)
     .addInterceptor(new CustomInterceptor())
     .build();
		// 发起请求
        this.client.newCall(request).execute().then((result) => {
            if (result) {
              this.status = result.responseCode.toString();
            }
            if (result.result)
            this.content = result.result;
            else
            this.content = JSON.stringify(result.response);
        }).catch((error) => {
            this.content = JSON.stringify(error);
        });
```

```typescript
import {Interceptor,Chain,Response,Logger} from '@ohos/httpclient';

class CustomInterceptor implements Interceptor {
  intercept(chain: Chain): Promise<Response> {
    return new Promise<Response>(function (resolve, reject) {
      let request = chain.requestI();
      Logger.info("request = " + request)
      Logger.info("inside AES interceptor request" + JSON.stringify(request.body.content))
      let encrypted = CryptoJS.AES.encrypt(request.body.content, CryptoJS.enc.Utf8.parse(secretKey), {
        iv: CryptoJS.enc.Utf8.parse('0000000000'),
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7,
        format: CryptoJS.format.Hex
      }).toString()
      request.body.content = encrypted;

      let response = chain.proceedI(request)
      Logger.info("response = " + response)
      response.then((data) => {
        resolve(data)
        Logger.info("inside AES interceptor response")
        let decrypted = CryptoJS.AES.decrypt(data.result, CryptoJS.enc.Utf8.parse(secretKey), {
          iv: CryptoJS.enc.Utf8.parse('0000000000'),
          mode: CryptoJS.mode.CBC,
          padding: CryptoJS.pad.Pkcs7,
          format: CryptoJS.format.Hex
        }).toString()
        Logger.log("AES decrypt = " + decrypted);
        data.result = decrypted;
      }).catch((err) => {
        reject(err)
      })
    })
  }
}
```

### 自定义请求示例

同步自定义请求

```typescript
import {HttpClient,Request,RequestBody,TimeUnit,Logger} from '@ohos/httpclient';

let request = new Request.Builder()
    .url("https://postman-echo.com/post")// 配置对应url
    .post(RequestBody.create("test123"))
    .addHeader("Content-Type", "text/plain")
    .setEntryObj(new Weather()) //设置自定义请求的实体对象
    .build();

this.client.newCall(request)
    .executed() // 发起同步请求
    .then(result => { 
        // 得到的是一个自定义请求类型的对象
        Logger.info('Custom Request Result' + JSON.stringify(result));
    })
    .catch(err => {
        Logger.error('Custom Request Error' + JSON.stringify(err));
    });
```

异步自定义请求

```typescript
 let request = new Request.Builder()
    .url("https://postman-echo.com/post") // 配置对应url
    .post(RequestBody.create("test123"))
    .addHeader("Content-Type",  "text/plain")
    .setEntryObj(new Weather(), true) //设置自定义请求的实体对象,异步需要传入true,否则执行的是常规请求
    .build();

this.client.newCall(request)
    // 发起异步请求
    .enqueue((result) => {
        // 得到的是一个自定义请求类型的对象
        Logger.info('Custom Request Result == ' + JSON.stringify(result));
    }, (error) => {
        Logger.error('Custom Request error == ' + JSON.stringify(error));
    })
```

### Multipart/form-data示例

创建RequestBody并使用创建的RequestBoy初始化MultiPart生成器

```javascript
import {HttpClient,Request,RequestBody,MultiPart,TimeUnit,Mime,Logger} from '@ohos/httpclient';

let requestBody1 = RequestBody.create({Title: 'Multipart', Color: 'Brown'},new Mime.Builder().contentDisposition('form-data; name="myfile"').contentType('text/plain', 'charset', 'utf8').build().getMime())
let requestBody2 = RequestBody.create("HttpClient",new Mime.Builder().contentDisposition('form-data; name="http"').contentType('text/plain', 'charset', 'utf8').build().getMime())
let requestBody3 = RequestBody.create(data,new Mime.Builder().contentDisposition('form-data; name="file";filename="httpclient.txt"').contentType('text/plain', 'charset', 'utf8').build().getMime())
let boundary = "webKitFFormBoundarysioud821";

let multiPartObj = new MultiPart.Builder()
    .type(httpclient.MultiPart.FORMDATA)
    .addPart(requestBody1)
    .addPart(requestBody2)
    .addPart(requestBody3)
    .build();
let body = multiPartObj.createRequestBody();
```

在请求/响应中使用multipart

```javascript
let request =  new Request.Builder()
    .url(this.echoServer)
    .post(body)
    .addHeader("Content-Type", "multipart/form-data")
    .params("LibName", "HttpClient-ohos")
    .params("Request", "MultiData")
    .build()
```

### 身份认证

创建client、request对象，使用NetAuthenticator对象对用户名和密码加密进行身份认证

```javascript
import {HttpClient,Request,NetAuthenticator,TimeUnit,Mime,Logger} from '@ohos/httpclient';

let client = new HttpClient.Builder().setConnectTimeout(10,TimeUnit.SECONDS)
    .authenticator(new NetAuthenticator('jesse', 'password1'))
    .build();
 let request = new Request.Builder()
    .get("https://publicobject.com/secrets/hellosecret.txt")
    .addHeader("Content-Type", "application/json")
    .build();

 client.newCall(request).execute().then((result) => {
     Logger.info('authenticator:' + result.responseCode.toString())
     if (result) {
         Logger.info('authenticator:' + result.responseCode.toString())
     }
 })
```
### 证书校验

将证书文件放入resources的rawfile文件件下，例如将client_rsa_private.pem.unsecure私钥文件放入rawfile文件夹下
```javascript
import  { HttpClient, RealTLSSocket, Request, StringUtil, TLSSocketListener, Utils } from '@ohos/httpclient';

let currentALPNProtocols = ["spdy/1", "http/1.1"]
let currentPasswd = "123456"
let currentSignatureAlgorithms = "rsa_pss_rsae_sha256:ECDSA+SHA256"
let currentCipherSuites = "AES256-SHA256"
let ifUseRemoteCipherPrefer = true
let protocols = [socket.Protocol.TLSv12]

let keyRes = 'client_rsa_private.pem.unsecure'
let certRes = 'client.crt'
let caRes = ['ca.crt']
let url = "https://106.15.92.248:5555"

let client = new HttpClient.Builder().build();
let realTlsSocet = new RealTLSSocket();

let hereResourceManager: resmgr.ResourceManager = getContext().resourceManager;

realTlsSocet.setLisenter(new TLSSocketListenerImpl(this.content))
realTlsSocet.setKeyDataByRes(hereResourceManager, keyRes, (errKey, resultKey) => {
})
.setCertDataByRes(hereResourceManager, certRes, (errCert, resulterrKey) => {
})
.setCaDataByRes(hereResourceManager, caRes, (errCa, resultCa) => {
})
.setUseRemoteCipherPrefer(ifUseRemoteCipherPrefer)
.setSignatureAlgorithms(currentSignatureAlgorithms)
.setCipherSuites(currentCipherSuites)
.setPasswd(currentPasswd)
.setProtocols(protocols)
.setALPNProtocols(currentALPNProtocols)

let request: Request = new Request.Builder().setTlsRequst(realTlsSocet).url(url).build();
client.newCall(request).execute()

class TLSSocketListenerImpl extends TLSSocketListener {

    constructor(content: string) {
    super(content);
}

onBind(err: string, data: string): void {
    if (!!!err) {
        this.content += '\ntlsSoket:onBind:data:绑定成功'
        this.content += '\ntlsSoket:onBind:data:正在链接..'
    } else {
        this.content += '\ntlsSoket:onBind:err:' + JSON.stringify(err)
    }
}

onMessage(err: string, data: object): void {
    if (!!!err) {
      let bufferContent = buffer.from(data['message'])
      let unitString: ArrayBuffer = JSON.parse(JSON.stringify(bufferContent)).data;
      let resultData: ESObject = Utils.Utf8ArrayToStr(unitString);
      this.content += '\ntlsSoket:onMessage:接收服务器消息:' + JSON.stringify(resultData)
      this.content += '\ntlsSoket:onMessage:服务器路由:' + JSON.stringify(data['remoteInfo'])
    } else {
        this.content += '\ntlsSoket:onMessage:接收服务器消息:err:' + JSON.stringify(err)
    }
}

onConnect(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:onConnect:data:' + ((!!data && data != undefined) ? data : '连接成功')
    } else {
        this.content += '\ntlsSoket:onConnect:err:' + JSON.stringify(err)
        if (err['code'] == 0) {
            this.content += '\ntlsSoket:onConnect:err:连接不上服务器，请确认服务器是否可用，确认客户端是否联网'
        }
    }
}

onSend(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:onSend:data:发送成功'
    } else {
        this.content += '\ntlsSoket:onSend:err:' + JSON.stringify(err)
    }
}

onClose(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:onClose:data:' + data
    } else {
        this.content += '\ntlsSoket:onClose:err:' + JSON.stringify(err)
    }
}

onError(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:onError:data:' + data
    } else {
        this.content += '\ntlsSoket:onError:err:' + JSON.stringify(err)
        if (err['errorNumber'] = -1 || JSON.stringify(err).includes('951')) {
            this.content += '\ntlsSoket:onError:err:连接不上服务器，请确认服务器是否可用，确认客户端是否联网'
        }
    }
}

onVerify(verifyName: string, err: string, data: string) {
    if (!!!err) {
        this.content += '\n' + verifyName + ':校验证书通过'
        this.content += '\n校验证书数据:' + data
    } else {
        this.content += '\n' + verifyName + ' err:' +JSON.stringify(err)
    }
    this.content += '\n'
}

setExtraOptions(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:setExtraOptions:data:设置成功'
    } else {
        this.content += '\ntlsSoket:setExtraOptions:err:' + JSON.stringify(err)
    }
}

offConnect(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:offConnect:data:' + data
    } else {
        this.content += '\ntlsSoket:offConnect:err:' + JSON.stringify(err)
    }
}

offClose(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:offClose:data:' + data
    } else {
        this.content += '\ntlsSoket:offClose:err:' + JSON.stringify(err)
    }
}

offMessage(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:offMessage:data:' + data
    } else {
        this.content += '\ntlsSoket:offMessage:err:' + JSON.stringify(err)
    }
}

offError(err: string, data: string) {
    if (!!!err) {
        this.content += '\ntlsSoket:offError:data:' + data
    } else {
        this.content += '\ntlsSoket:offError:err:' + JSON.stringify(err)
    }
  }
}

```

### 自定义证书校验

将证书文件放入resources的rawfile文件件下，例如将CA证书ca.crt文件放入rawfile文件夹下

```typescript
let client: HttpClient = new HttpClient
  .Builder()
  .setConnectTimeout(10, TimeUnit.SECONDS)
  .setReadTimeout(10, TimeUnit.SECONDS)
  .build();
Logger.info(TAG, 'HttpClient end');
let context: Context = getContext();
let CA: string = await new GetCAUtils().getCA(this.ca, context);
Logger.info(TAG, 'request begin');
Logger.info(TAG, 'CA:', JSON.stringify(CA));
let request: Request = new Request.Builder()
  .url(this.url)
  .method('GET')
  .ca([CA])
  .build();
Logger.info(TAG, 'request end');
client.newCall(request)
  .checkCertificate(new SslCertificateManagerSuccess())
  .enqueue((result: Response) => {
    this.result = "自定义证书return success, result: " + JSON.stringify(JSON.parse(JSON.stringify(result)), null, 4);
    Logger.info(TAG, "自定义证书return success, result: " + JSON.stringify(JSON.parse(JSON.stringify(result)), null, 4));
  }, (err: Response) => {
    this.result = "自定义证书return failed, result: " + JSON.stringify(err);
    Logger.info(TAG, "自定义证书return failed, result: ", JSON.stringify(err));
  });

export class SslCertificateManager implements X509TrustManager {
  checkServerTrusted(X509Certificate: certFramework.X509Cert): void {
    Logger.info(TAG, 'Get Server Trusted X509Certificate');
    // 时间校验成功的设置值
    let currentDayTime = StringUtil.getCurrentDayTime();
    let date = currentDayTime + 'Z';
    try {
      X509Certificate.checkValidityWithDate(date); // 检查X509证书有效期
      console.error('checkValidityWithDate success');
    } catch (error) {
      console.error('checkValidityWithDate failed, errCode: ' + error.code + ', errMsg: ' + error.message);
      error.message = 'checkValidityWithDate failed, errCode: ' + error.code + ', errMsg: ' + error.message;
      throw new Error(error);
    }
  }

  checkClientTrusted(X509Certificate: certFramework.X509Cert): void {
    Logger.info(TAG, 'Get Client Trusted X509Certificate');
    let encoded = X509Certificate.getEncoded(); // 获取X509证书序列化数据
    Logger.info(TAG, 'encoded: ', JSON.stringify(encoded));
    let publicKey = X509Certificate.getPublicKey(); // 获取X509证书公钥
    Logger.info(TAG, 'publicKey: ', JSON.stringify(publicKey));
    let version = X509Certificate.getVersion(); // 获取X509证书版本
    Logger.info(TAG, 'version: ', JSON.stringify(version));
    let serialNumber = X509Certificate.getCertSerialNumber(); //获取X509证书序列号
    Logger.info(TAG, 'serialNumber: ', serialNumber);
    let issuerName = X509Certificate.getIssuerName(); // 获取X509证书颁发者名称
    Logger.info(TAG, 'issuerName: ', Utils.Uint8ArrayToString(issuerName.data));
    let subjectName = X509Certificate.getSubjectName(); // 获取X509证书主体名称
    Logger.info(TAG, 'subjectName: ', Utils.Uint8ArrayToString(subjectName.data));
    let notBeforeTime = X509Certificate.getNotBeforeTime(); // 获取X509证书有效期起始时间
    Logger.info(TAG, 'notBeforeTime: ', notBeforeTime);
    let notAfterTime = X509Certificate.getNotAfterTime(); // 获取X509证书有效期截止时间
    Logger.info(TAG, 'notAfterTime: ', notAfterTime);
    let signature = X509Certificate.getSignature(); // 获取X509证书签名数据
    Logger.info(TAG, 'signature: ', Utils.Uint8ArrayToString(signature.data));
    let signatureAlgName = X509Certificate.getSignatureAlgName(); // 获取X509证书签名算法名称
    Logger.info(TAG, 'signatureAlgName: ', signatureAlgName);
    let signatureAlgOid = X509Certificate.getSignatureAlgOid(); // 获取X509证书签名算法的对象标志符OID(Object Identifier)
    Logger.info(TAG, 'signatureAlgOid: ', signatureAlgOid);
    let signatureAlgParams = X509Certificate.getSignatureAlgParams(); // 获取X509证书签名算法参数
    Logger.info(TAG, 'signatureAlgParams: ', Utils.Uint8ArrayToString(signatureAlgParams.data));
    let keyUsage = X509Certificate.getKeyUsage(); // 获取X509证书秘钥用途
    Logger.info(TAG, 'keyUsage: ', Utils.Uint8ArrayToString(keyUsage.data));
    let extKeyUsage = X509Certificate.getExtKeyUsage(); //获取X509证书扩展秘钥用途
    Logger.info(TAG, 'extKeyUsage: ', JSON.stringify(extKeyUsage));
    let basicConstraints = X509Certificate.getBasicConstraints(); // 获取X509证书基本约束
    Logger.info(TAG, 'basicConstraints: ', JSON.stringify(basicConstraints));
    let subjectAltNames = X509Certificate.getSubjectAltNames(); // 获取X509证书主体可选名称
    Logger.info(TAG, 'subjectAltNames: ', JSON.stringify(subjectAltNames));
    let issuerAltNames = X509Certificate.getIssuerAltNames(); // 获取X509证书颁发者可选名称
    Logger.info(TAG, 'issuerAltNames: ', JSON.stringify(issuerAltNames));
    let tbs = X509Certificate.getItem(certFramework.CertItemType.CERT_ITEM_TYPE_TBS).data; // 获取X509证书TBS(to be signed)
    Logger.info(TAG, 'tbs: ', base64.fromByteArray(tbs));
    let pubKey = X509Certificate.getItem(certFramework.CertItemType.CERT_ITEM_TYPE_PUBLIC_KEY); // 获取X509证书公钥.
    Logger.info(TAG, 'pubKey: ', base64.fromByteArray(pubKey.data));
    let extensions = X509Certificate.getItem(certFramework.CertItemType.CERT_ITEM_TYPE_EXTENSIONS).data;
    Logger.info(TAG, 'extensions: ', base64.fromByteArray(extensions));
  }
}
```

### WbSocket接口请求示例

```javascript
import { HttpClient, RealWebSocket, Request, TimeUnit, WebSocket, WebSocketListener,Logger } from '@ohos/httpclient';

class MyWebSocketListener implements WebSocketListener {

    onOpen(webSocket: RealWebSocket, response: string) {
        Logger.info("ws------onOpen");
    };

    onMessage(webSocket: RealWebSocket, text: string) {
        Logger.info("ws------onMessage");
    };

    onClosing(webSocket: RealWebSocket, code: number, reason: string) {
        Logger.info("ws------onClosing");
    };

    onClosed(webSocket: RealWebSocket, code: number, reason: string) {
        Logger.info("ws------onClosed");
    };

    onFailure(webSocket: RealWebSocket, e: Error, response?: string) {
        Logger.error("ws------onFailure--" + e.message);
    };
}


let client = new HttpClient
        .Builder()
        .setConnectTimeout(10, TimeUnit.SECONDS)
        .setReadTimeout(10, TimeUnit.SECONDS)
        .build();

let request = new Request.Builder()
        .url(this.url)
        .params("","")
        .params("","")
        .build();

//发起websocket请求
ws = client.newWebSocket(request, new MyWebSocketListener(this.connectStatus, this.chatArr));

//向服务器发送消息
ws.send(this.msg).then((isSuccess) => {
  if (isSuccess) {
    this.chatArr.push(new User(1, this.msg))
    Logger.info("ws------sendMessage--success:");
  } else {
    Logger.error("ws------sendMessage--FAIL:");
  }
})

```

### 自定义DNS解析

通过dns()接口lookup自定义DNS解析：只进行解析

```javascript
import { Chain, Dns, HttpClient, Interceptor, Request, Response, TimeUnit, Utils,Logger } from '@ohos/httpclient';

export class CustomDns implements Dns {
  lookup(hostname: string): Promise<Array<connection.NetAddress>> {
    return new Promise((resolve, reject) => {
      connection.getAddressesByName(hostname).then((netAddress) => {
        resolve(netAddress)
      }).catch((err: BusinessError) => {
        reject(err)
      });
    })
  }
}

let client = new HttpClient.Builder()
        .dns(new CustomDns())
        .setConnectTimeout(10, TimeUnit.SECONDS)
        .setReadTimeout(10, TimeUnit.SECONDS)
        .build();

let request = new Request.Builder().url(this.url).build();

client.newCall(request).enqueue((result) => {
        Logger.info("dns---success---" + JSON.stringify(result));
                    }, (err) => {
    Logger.error("dns---failed---" + JSON.stringify(err));
});

```

通过dns()接口lookup自定义dns解析：传入自定义DNS
```javascript
import { Chain, Dns, HttpClient, Interceptor, Request, Response, TimeUnit, Utils,Logger } from '@ohos/httpclient';

export class CustomAddDns implements Dns {
  lookup(hostname: string): Promise<Array<connection.NetAddress>> {
    return new Promise((resolve, reject) => {
      connection.getAddressesByName(hostname).then((netAddress) => {
          netAddress.push({'address': 'xx.xx.xx.xx'});
          resolve(netAddress)
      }).catch((err: BusinessError) => {
        reject(err)
      });
    })
  }
}

let client = new HttpClient.Builder()
        .dns(new CustomDns())
        .setConnectTimeout(10, TimeUnit.SECONDS)
        .setReadTimeout(10, TimeUnit.SECONDS)
        .build();

let request = new Request.Builder().url(this.url).build();

client.newCall(request).enqueue((result) => {
        Logger.info("dns---success---" + JSON.stringify(result));
                    }, (err) => {
    Logger.error("dns---failed---" + JSON.stringify(err));
});
```

通过dns()接口lookup自定义dns解析：重定向DNS
```javascript
import { Chain, Dns, HttpClient, Interceptor, Request, Response, TimeUnit, Utils,Logger } from '@ohos/httpclient';

export class CustomAddDns implements Dns {
  lookup(hostname: string): Promise<Array<connection.NetAddress>> {
    return  new Promise((resolve, reject) => {
      connection.getAddressesByName(hostname).then((netAddress) => {
          netAddress = [{'address': 'xxx.xx.xx.xxx'}];
          resolve(netAddress)
      }).catch((err: BusinessError) => {
        reject(err)
      });
    })
  }
}

let client = new HttpClient.Builder()
        .dns(new CustomDns())
        .setConnectTimeout(10, TimeUnit.SECONDS)
        .setReadTimeout(10, TimeUnit.SECONDS)
        .build();

let request = new Request.Builder().url(this.url).build();

client.newCall(request).enqueue((result) => {
        Logger.info("dns---success---" + JSON.stringify(result));
                    }, (err) => {
    Logger.error("dns---failed---" + JSON.stringify(err));
});
```

通过拦截器接口自定义DNS解析

```javascript
export class CustomInterceptor implements Interceptor {
    intercept(chain: Chain): Promise<Response> {
        return new Promise<Response>(function (resolve, reject) {
            let originRequest = chain.requestI();
            let url = originRequest.url.getUrl();
            let host = Utils.getDomainOrIp(url)
    connection.getAddressesByName(host).then(function (netAddress) {
                let newRequest = originRequest.newBuilder()
                if (!!netAddress) {
                    url = url.replace(host, netAddress[0].address)
                    newRequest.url(url)
                }
                let newResponse = chain.proceedI(newRequest.build())
                resolve(newResponse)
            }).catch(err => {
                resolve(err)
            });
        })
    }
}

let client = new HttpClient
        .Builder()
        //设置自定义拦截器
        .addInterceptor(new CustomInterceptor())
        .setConnectTimeout(10, TimeUnit.SECONDS)
        .setReadTimeout(10,TimeUnit.SECONDS)
        .build();

let request = new Request.Builder().url(this.url).build();

client.newCall(request).enqueue((result) => {
        Logger.info("dns---success---" + JSON.stringify(result));
                    }, (err) => {
    Logger.error("dns---failed---" + JSON.stringify(err));
});
```

### 响应缓存示例

添加响应缓存示例

```javascript
import {
    Cache,
    CacheControl,
    Dns,
    HttpClient,
    Logger,
    Request,
    Response,
    StringUtil,
    TimeUnit,
    Utils,
    X509TrustManager
} from '@ohos/httpclient';
import { Utils as GetCAUtils } from "../utils/Utils";

caPem = "noPassword/ca.pem";
let cache = new Cache.Cache(getContext().cacheDir, 10 * 1024 * 1024, getContext());
let httpClient = new HttpClient
    .Builder().dns(new CustomDns())
    .cache(cache)
    .setConnectTimeout(10000, TimeUnit.SECONDS)
    .setReadTimeout(10000, TimeUnit.SECONDS)
    .build();
let caFile: string = await new GetCAUtils().getCA(this.caPem, context);

// 服务端返回header请求
let request = new Request.Builder()
    .get()
    .url('https://1.94.37.200:8080/cache/e/tag')
    .ca([caFile])
    .build();
// 手动设置header请求
request = new Request.Builder()
    .get()
    .url('https://1.94.37.200:8080/cache/max/age')
    .addHeader("Cache-Control", "max-age=30")
    .ca([caFile])
    .build();
// 手动设置cache请求
request = new Request.Builder()
    .get()
    .url('https://1.94.37.200:8080/cache/no/cache')
    .cacheControl(CacheControl.FORCE_CACHE())
    .ca([caFile])
    .build();

httpClient
    .newCall(request)
    .checkCertificate(new sslCertificateManager())
    .execute().then((result) => {
    ...
})

export class CustomDns implements Dns {
    ...
}

export class SslCertificateManager implements X509TrustManager {
    ...
}

```

### 请求配置responseData属性示例

添加请求配置responseData属性示例

```javascript
import { HttpClient, Request, Logger, TimeUnit, Response , HttpDataType} from '@ohos/httpclient';

let client: HttpClient = new HttpClient.Builder()
    .setConnectTimeout(1000, TimeUnit.SECONDS)
    .setReadTimeout(1000, TimeUnit.SECONDS)
    .setWriteTimeout(1000, TimeUnit.SECONDS)
    .build();

let request = new Request.Builder()
    .get("https://postman-echo.com/get?foo1=bar1&foo2=bar2")
    .addHeader("Content-Type", "application/json")
    .setHttpDataType(HttpDataType.STRING)
    .build();

client.newCall(request).execute().then((result: Response) => {})

```

### 请求优先级

设置请求优先级

```javascript
import { HttpClient, Request, Logger } from '@ohos/httpclient';

// 配置请求优先级
let request = new Request.Builder()
    .get('https://postman-echo.com/get?foo1=bar1&foo2=bar2')
    .setPriority(5)
    .build();
// 发起请求
this.client.newCall(request).enqueue((result) => {
    if (result) {
        this.status = result.responseCode.toString();
    }
    if (result.result) {
        this.content = result.result;
    } else {
        this.content = JSON.stringify(result);
    }
    Logger.info("onComplete -> Status : " + this.status);
    Logger.info("onComplete -> Content : " + JSON.stringify(this.content));
}, (error)=> {
    this.status = error.code.toString();
    this.content = error.data;
    Logger.info("onError -> Error : " + this.content);
});

```


### 网络事件监听

设置网络事件监听

```javascript
import { Dns, HttpClient, Request, Response, BusinessError, IOException, EventListener, HttpCall } from '@ohos/httpclient';

// 自定义网络事件监听
let client = new HttpClient.Builder()
    .addEventListener(new HttpEventListener())
    .build();

let request = new Request.Builder()
    .get(this.url)
    .build();

client.newCall(request).execute().then((result) => {})

class HttpEventListener extends EventListener {
    protected startTime: number = 0;

    logWithTime(message: string) {
        const nosTime: number = new Date().getTime();
        if (message == 'callStart') {
          this.startTime = nosTime;
        }
        const elapsedTime: number = (nosTime - this.startTime) / 1000;
        Logger.info('自定义EventListener' +  elapsedTime + ' ' + message );
    }
    
    callStart(call: HttpCall) {
        this.logWithTime('callStart');
    };
    
    requestHeadersStart(call: HttpCall) {
    	this.logWithTime('requestHeadersStart');
	}

	requestHeadersEnd(call: HttpCall, request: Request) {
	    this.logWithTime('requestHeadersEnd');
	}


  ...

}

```

### 证书锁定示例

设置证书锁定

```
import {
    Dns,
    HttpClient,
    Request,
    Response,
    TimeUnit,
    CertificatePinnerBuilder
} from '@ohos/httpclient';
import { Utils } from "../utils/Utils";

let certificatePinner = new CertificatePinnerBuilder()
    .add('1.94.37.200', 'sha256/WAFcHG6pAINrztx343nlM3jYzLOdfoDS9pPgMvD2XHk=')
    .build()
let client: HttpClient = new HttpClient
    .Builder()
    .dns(new CustomDns())
    .setConnectTimeout(10, TimeUnit.SECONDS)
    .setReadTimeout(10, TimeUnit.SECONDS)
    .build();
let context: Context = getContext();
let CA: string = await new Utils().getCA('caPin.crt', context);
let request: Request = new Request.Builder()
    .url('https://1.94.37.200:8080/user/getUserByUuid?userUuid=1')
    .method('GET')
    .ca([CA])
    .build();
client.newCall(request)
    .setCertificatePinner(certificatePinner)
    .enqueue((result: Response) => {
        this.result = "响应结果success" + JSON.stringify(JSON.parse(JSON.stringify(result)), null, 4)
        Logger.info("证书锁定---success---" + JSON.stringify(JSON.parse(JSON.stringify(result)), null, 4));
    }, (err: BusinessError) => {
        this.result = "响应结果fail" + JSON.stringify(err)
        Logger.info("证书锁定---failed--- ", JSON.stringify(err));
    });
```

### 添加代理示例

添加代理示例

```javascript
import {Cache,Chain,DnsResolve,FormEncoder,HttpClient,Interceptor, Mime,MultiPart,Request,RequestBody,Response} from '@ohos/httpclient';

let client: HttpClient = new HttpClient
    .Builder()
    .setProxy(new Proxy(Type.HTTP,'xx.xx.xx.xx',80))
    .setConnectTimeout(10, TimeUnit.SECONDS)
    .setReadTimeout(10, TimeUnit.SECONDS)
    .build();
let request: Request = new Request.Builder()
    .url('http://publicobject.com/helloworld.txt')
    .method('GET')
    .build();

CacheClient.newCall(request).execute().then((result) => {})
```

### OS错误返回码链接

https://gitee.com/openharmony/docs/blob/master/zh-cn/application-dev/reference/apis/js-apis-http.md#responsecode



## 接口说明

### Request.Builder

| 接口名                      | 参数                         | 返回值             | 说明                                       |
| ------------------------ | -------------------------- | --------------- | ---------------------------------------- |
| setAbilityContext        | abilityContext             | Request.Builder | 设置上下文，用于上传下载的参数                          |
| convertor                | convertorType              | Request.Builder | 设置转换器类型，用于将响应结果解析转换为需要的类型                |
| setCookieJar             | cookieJar                  | Request.Builder | 设置cookieJar，用于自动获取缓存的cookie，并自动设置给请求头    |
| setCookieManager         | cookieManager              | Request.Builder | 设置cookie管理器，用于设置cookie策略                 |
| retryOnConnectionFailure | isRetryOnConnectionFailure | Request.Builder | 设置当前请求失败是否重试                             |
| retryMaxLimit            | maxValue                   | Request.Builder | 设置当前请求可以重试的最大次数                          |
| retryConnectionCount     | count                      | Request.Builder | 设置当前请求当前已经重试次数                           |
| followRedirects          | aFollowRedirects           | Request.Builder | 设置当前请求是否是允许重定向                           |
| redirectMaxLimit         | maxValue                   | Request.Builder | 设置当前请求可以重定向的最大次数                         |
| redirectionCount         | count                      | Request.Builder | 设置当前请求当前已经重定向次数                          |
| addInterceptor           | req, resp                  | Request.Builder | 添加拦截器，req参数是请求拦截器，resp是响应拦截器。本方法允许多次调用添加多个拦截器。参数允许为空。 |
| headers                  | value                      | Request.Builder | 当前请求设置请求头                                |
| cache                    | value                      | Request.Builder | 设置当前请求开启缓存                                |
| addHeader                | key, value                 | Request.Builder | 当前请求的请求头添加参数                             |
| setDefaultUserAgent      | value                      | Request.Builder | 当前请求设置默认的用户代理，它是一个特殊字符串头，使得服务器能够识别客户使用的操作系统及版本、CPU 类型、浏览器及版本、浏览器渲染引擎、浏览器语言、浏览器插件等。 |
| setDefaultContentType    | value                      | Request.Builder | 当前请求设置默认的媒体类型信息。                         |
| body                     | value                      | Request.Builder | 当前请求设置请求体                                |
| url                      | value                      | Request.Builder | 当前请求设置请求地址                               |
| tag                      | value                      | Request.Builder | 当前请求设置标签，用于取消请求                          |
| method                   | value                      | Request.Builder | 当前请求设置请求请求方式                             |
| params                   | key, value                 | Request.Builder | 当前请求设置请求参数，用于拼接在请求路径url后面                |
| addFileParams            | files, data                | Request.Builder | 当前请求添加文件上传参数                             |
| setFileName              | name                       | Request.Builder | 当前请求设置文件名，用于下载请求                         |
| get                      | url                        | Request.Builder | 当前请求的请求方式设置为GET，如果参数url不为空则还需为request设置请求路径url |
| put                      | body                       | Request.Builder | 当前请求的请求方式设置为PUT，如果参数body不为空则还需为request设置请求体body |
| delete                   | 暂无                         | Request.Builder | 当前请求的请求方式设置为DELETE                       |
| head                     | 暂无                         | Request.Builder | 当前请求的请求方式设置为HEAD                         |
| options                  | 暂无                         | Request.Builder | 当前请求的请求方式设置为OPTIONS                      |
| post                     | body                       | Request.Builder | 当前请求的请求方式设置为POST，如果参数body不为空则还需为request设置请求体body |
| upload                   | files, data                | Request.Builder | 当前请求的请求方式设置为UPLOAD，同时设置文件列表参数files和额外参数data |
| download                 | url,filename               | Request.Builder | 当前请求的请求方式设置为DOWNLOAD，如果参数filename不为空则还需为request设置文件名filename |
| trace                    | 暂无                         | Request.Builder | 当前请求的请求方式设置为TRACE                        |
| connect                  | 暂无                         | Request.Builder | 当前请求的请求方式设置为CONNECT                      |
| setDefaultConfig         | defaultConfig              | Request.Builder | 当前请求添加默认配置，主要包括设置默认的content_type和user_agent，可以通过传入一个json文件的方式来全局配置 |
| build                    | 暂无                         | Request.Builder | 当前请求根据设置的各种参数构建一个request请求对象             |
| setEntryObj              |  value,flag                  | Request.Builder | 设置自定义请求对象，第一个参数是自定义实体空对象，第二个参数异步请求需要传入true用来表示是自定义请求，同步可不传，默认为false          |
| setHttpDataType          | HttpDataType                 | Request.Builder | 返回设置响应的数据类型,未设置该属性时，默认返回string数据类型。                                                |
| setPriority              | number                     | Request.Builder | 当前请求设置优先级                                         |

### HttpClient.Builder

| 接口名               | 参数                             | 返回值                | 说明                                       |
| ----------------- |--------------------------------| ------------------ | ---------------------------------------- |
| addInterceptor    | aInterceptor                   | HttpClient.Builder | 为HTTP请求客户端添加拦截器，用于在发起请求之前或者获取到相应数据之后进行某些特殊操作 |
| authenticator     | aAuthenticator                 | HttpClient.Builder | 为HTTP请求客户端添加身份认证，可以在请求头中添加账号密码等信息。       |
| setConnectTimeout | timeout, unit                  | HttpClient.Builder | 为HTTP请求客户端设置连接超时时间                       |
| setReadTimeout    | timeout, unit                  | HttpClient.Builder | 为HTTP请求客户端设置读取超时时间                       |
| setWriteTimeout   | timeout, unit                  | HttpClient.Builder | 为HTTP请求客户端设置写入超时时间                       |
| _setTimeOut       | timeout, timeUnit, timeoutType | HttpClient.Builder | 为HTTP请求客户端设置超时时间，根据timeoutType来区分是连接超时时间还是读取超时时间或者是写入超时时间。 |
| build             | 暂无                             | HttpClient.Builder | 构建HTTP请求客户端对象                            |
| dns               | dns: Dns                       | HttpClient.Builder | 设置自定义DNS解析                          |
| addEventListener               | EventListener                  | HttpClient.Builder | 添加网络事件监听                                        |
| setProxy        | type,host,port                 | HttpClient.Builder |                                                 |
### HttpCall

| 接口名                | 参数   | 返回值        | 说明                |
| ------------------ | ---- | ---------- | ----------------- |
| getRequest         | 暂无   | Request    | 获取当前请求任务的请求对象     |
| getClient          | 暂无   | HttpClient | 获取当前请求任务的请求客户端    |
| execute            | 暂无   | Promise    | 当前请求任务发起同步请求      |
| enqueue            | 暂无   | 暂无         | 当前请求任务发起异步请求      |
| getSuccessCallback | 暂无   | Callback   | 获取当前请求任务的请求成功回调接口 |
| getFailureCallback | 暂无   | Callback   | 获取当前请求任务的请求失败回调接口 |
| cancel             | 暂无   | 暂无         | 取消当前请求任务          |
| isCancelled        | 暂无   | Boolean    | 获取当前请求任务是否成功取消了   |
| executed           | 暂无   | Promise      | 当前自定义请求任务发起同步请求   |
| checkCertificate | X509TrustManager | HttpCall | 设置自定义证书校验函数 |
| setCertificatePinner | certificatePinner | HttpCall | 设置证书锁定 |

### X509TrustManager

| 接口名             | 参数                   | 返回值 | 说明           |
| ------------------ | ---------------------- | ------ | -------------- |
| checkClientTrusted | certFramework.X509Cert | void   | 校验客户端证书 |
| checkServerTrusted | certFramework.X509Cert | void   | 校验服务器证书 |

### WebSocket

| 接口名                 | 参数                      | 返回值       | 说明                          |
| ------------------- | ----------------------- | --------- | --------------------------- |
| request        | 暂无                      | Request | 获取Request             |
| queueSize           | 暂无                   | number | 获取队列大小            |
| send         | text: string  ArrayBuffer | Promise<boolean>        | 向服务器发送消息 |
| close   | code: number, reason?: string      | Promise<boolean>        | 断开连接     |### WebSocket

### WebSocketListener

| 接口名                 | 参数                      | 返回值       | 说明                          |
| ------------------- | ----------------------- | --------- | --------------------------- |
| onOpen        | webSocket: RealWebSocket, response: string                      | void | WebSocket连接成功监听回调             |
| onMessage           | webSocket: RealWebSocket, text: string  ArrayBuffer        | void | WebSocket服务端响应监听回调             |
| onClosed         | webSocket: RealWebSocket, code: number, reason: string | void       |  WebSocket连接关闭监听回调
| onFailure   | webSocket: RealWebSocket, e: Error, response?: string   | void      | WebSocket连接失败监听回调    |

### RealWebSocket

| 接口名                 | 参数                      | 返回值       | 说明                          |
| ------------------- | ----------------------- | --------- | --------------------------- |
| request        | 暂无                      | Request | 获取Request             |
| queueSize           | 暂无                   | number | 获取队列大小            |
| send         | text: string  ArrayBuffer   | Promise<boolean>        | 向服务器发送消息 |
| close   | code: number, reason?: string      | Promise<boolean>        | 断开连接    |### WebSocket

### RequestBody

| 接口名    | 参数                                       | 返回值         | 说明              |
| ------ | ---------------------------------------- | ----------- | --------------- |
| create | content : String/JSON Object of Key:Value pair | RequestBody | 创建RequestBody对象 |

### RequestBuilder

| 接口名             | 参数                       | 返回值            | 说明                  |
| --------------- | ------------------------ | -------------- | ------------------- |
| buildAndExecute | 无                        | void           | 构建并执行RequestBuilder |
| newCall         | 无                        | void           | 执行请求                |
| header          | name:String,value:String | RequestBuilder | 传入key、value构建请求头    |
| connectTimeout  | timeout:Long             | RequestBuilder | 设置连接超时时间            |
| url             | value:String             | RequestBuilder | 设置请求url             |
| GET             | 无                        | RequestBuilder | 构建GET请求方法           |
| PUT             | body:RequestBody         | RequestBuilder | 构建PUT请求方法           |
| DELETE          | 无                        | RequestBuilder | 构建DELETE请求方法        |
| POST            | 无                        | RequestBuilder | 构建POST请求方法          |
| UPLOAD          | files:Array, data:Array  | RequestBuilder | 构建UPLOAD请求方法        |
| CONNECT         | 无                        | RequestBuilder | 构建CONNECT请求方法       |

### MimeBuilder

| 接口名         | 参数           | 返回值  | 说明                         |
| ----------- | ------------ | ---- | -------------------------- |
| contentType | value:String | void | 添加MimeBuilder contentType。 |

### FormEncodingBuilder

| 接口名   | 参数                       | 返回值  | 说明              |
| ----- | ------------------------ | ---- | --------------- |
| add   | name:String,value:String | void | 以键值对形式添加参数      |
| build | 无                        | void | 获取RequestBody对象 |

### FileUploadBuilder

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| addFile   | furi : String            | void | 添加文件URI到参数里用于上传 |
| addData   | name:String,value:String | void | 以键值对形式添加请求数据    |
| buildFile | 无                        | void | 生成用于上传的文件对象     |
| buildData | 无                        | void | 构建用于上传的数据       |

### BinaryFileChunkUploadBuilder

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| addBinaryFile   | abilityContext, chunkUploadOptions  | void | 添加分片上传配置信息 |
| addData   | name:String,value:String | void | 以键值对形式添加请求数据    |
| addUploadCallback | callback         | void | 添加上传完成/失败回调     |
| addUploadProgress | uploadProgressCallback | void | 添加上传进度回调     |

### RetryAndFollowUpInterceptor

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| intercept   | chain: Chain | Promise<Response> | 拦截响应结果 |
| followUpRequest   | request: Request, userResponse: Response | Request | 根据请求结果生成重试策略   |
| retryAfter | userResponse: Response, defaultDelay: number | number | 获取响应header中的Retry-After     |

### Dns

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| lookup   | hostname: String | Promise<Array<connection.NetAddress>> | 自定义DNS解析 |

### NetAuthenticator

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| constructor | userName: string, password: string | void | 添加用户名和密码 |
| authenticate | request: Request, response: Response | Request | 对请求头添加身份认证凭证    |

### RealTLSSocket

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| setCaDataByRes | resourceManager: resmgr.ResourceManager, resName: string[], callBack | void | 设置Ca证书或者证书链 |
| setCertDataByRes | resourceManager: resmgr.ResourceManager, resName: string, callBack | void | 设置本地数字证书 |
| setKeyDataByRes | resourceManager: resmgr.ResourceManager, resName: string, callBack | void | 设置密钥 |
| setOptions | options: socket.TLSSecureOptions | RealTLSSocket | 设置tls连接相关配置   |
| setAddress | ipAddress: string | void | 设置ip地址   |
| setPort | port: number | void | 设置端口   |
| bind | callback?:(err,data)=>void | void | 绑定端口   |
| connect | callback?:(err,data)=>void | void | 建立tls连接   |
| send | data, callback?:(err,data)=>void | void | 发送数据   |
| getRemoteCertificate | callback:(err,data)=>void | void | 获取远程证书   |
| getSignatureAlgorithms | callback:(err,data)=>void | void | 获取签名算法   |
| setVerify | isVerify: boolean | void | 设置是否校验证书   |
| verifyCertificate | callback:(err,data)=>void | void | 证书校验   |
| setCertificateManager | certificateManager: CertificateManager | void | 自定义证书校验 |

### TLSSocketListener

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| onBind | err: string, data: string | void | 绑定端口监听 |
| onMessage | err: string, data: string | void | 接收消息监听 |
| onConnect | err: string, data: string | void | 连接服务器监听 |
| onClose | err: string, data: string | void | 关闭监听 |
| onError | err: string, data: string | void | 错误监听 |
| onSend | err: string, data: string | void | 发送监听 |
| setExtraOptions | err: string, data: string | void | 设置其他属性操作监听 |

### CertificateVerify

| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| verifyCertificate | callback:(err,data)=>void | void | 证书校验 |
| verifyCipherSuite | callback:(err,data)=>void | void | 加密套件验证 |
| verifyIpAddress | callback:(err,data)=>void | void | 地址校验 |
| verifyProtocol | callback:(err,data)=>void | void | 通信协议校验 |
| verifySignatureAlgorithms | callback:(err,data)=>void | void | 签名算法校验 |
| verifyTime | callback:(err,data)=>void | void | 有效时间校验 |

### Cache
| 接口名       | 参数                               | 返回值  | 说明              |
| --------- |----------------------------------| ---- | --------------- |
| constructor | filePath: string,maxSize: number,context: Context| void | 设置journal创建的文件地址和大小 |
| key | url:string                       | string | 返回一个使用md5编码后的url |
| get | request: Request                 | Response | 根据request读取本地缓存的缓存信息 |
| put | response: Response               | string | 写入响应体 |
| remove | request: Request                 | void | 删除当前request的响应缓存信息 |
| evictAll | NA                               | void | 删除全部的响应缓存信息 |
| update | cache: Response, network: Response | void | 更新缓存信息 |
| writeSuccessCount | NA                               | number | 获取写入成功的计数 |
| size | NA                               | number | 获取当前缓存的大小 |
| maxSize | NA                               | number | 获取当前缓存的最大值 |
| flush | NA                               | void | 刷新缓存 |
| close | NA                               | void | 关闭缓存 |
| directory | NA                               | string | 获取当前文件所在的文件地址 |
| trackResponse | cacheStrategy: CacheStrategy.CacheStrategy | void | 设置命中缓存的计数 |
| trackConditionalCacheHit | NA                               | number | 增加跟踪条件缓存命中 |
| networkCount | NA                               | number | 添加网络计数 |
| hitCount | NA                               | number | 获取点击次数 |
| requestCount | NA                               | number | 获取请求的计数 |

### CacheControl
| 接口名       | 参数                       | 返回值  | 说明              |
| --------- | ------------------------ | ---- | --------------- |
| FORCE_NETWORK | NA | CacheControl | 强制请求使用网络请求 |
| FORCE_CACHE | NA | CacheControl | 强制请求使用缓存请求 |
| noCache | NA | boolean | 获取当前请求头或者响应头是否包含禁止缓存的信息 |
| noStore | NA | boolean | 获取当前请求头或者响应头是否包含禁止缓存的信息 |
| maxAgeSeconds | NA | number | 获取缓存的最大的存在时间 |
| sMaxAgeSeconds | NA | number | 获取缓存的最大的存在时间 |
| isPrivate | NA | boolean | 获取是否是私有的请求 |
| isPublic | NA | boolean | 获取是否是公有的请求 |
| mustRevalidate | NA | boolean | 获取是否需要重新验证 |
| maxStaleSeconds | NA | number | 获取最大的持续秒数 |
| minFreshSeconds | NA | number | 最短的刷新时间 |
| onlyIfCached | NA | boolean | 获取是否仅缓存 |
| noTransform | NA | boolean | 没有变化 |
| immutable | NA | boolean | 获取不变的 |
| parse | NA | CacheControl | 根据header创建 CacheControl|
| toString | NA | string | 获取缓存控制器转字符串 |
| Builder | NA | Builder | 获取CacheControl的Builder模式 |
| noCache | NA | Builder | 设置不缓存 |
| noStore | NA | Builder | 设置不缓存 |
| maxAge | maxAge: number | Builder | 设置最大的请求或响应的时效 |
| maxStale | NA | Builder | 设置不缓存 |
| onlyIfCached | NA | Builder | 设置仅缓存 |
| noTransform | NA | Builder | 设置没有变化 |
| immutable | NA | Builder | 设置获取不变的 |
| build | NA | CacheControl | Builder模式结束返回CacheControl对象 |

### gZipUtil
| 接口名       | 参数                       | 返回值  | 说明             |
| --------- | ------------------------ | ---- |----------------|
| gZipString | strvalue:string | Uint8Array | 编码Uint8Array数据 |
| ungZipString | strvalue:any | string | 解码字符串          |
| gZipFile |srcFilePath:string, targetFilePath:string | void | 编码文件           |
| ungZipFile | srcFilePath:string, targetFilePath:string | void | 解码文件           |
| stringToUint8Array | str:string | Uint8Array | 字符串转Uint8Array |

### HttpDataType
指定返回数据的类型。

| 接口名       | 值   | 说明       |
| --------- |-----|----------|
| STRING | 0   | 字符串类型。   |
| OBJECT	 | 1   | 对象类型。    |
| ARRAY_BUFFER | 2   | 二进制数组类型。 |

### CertificatePinnerBuilder

指定证书锁定内容。

| 接口名 | 参数                       | 返回值                   | 说明             |
| ------ | -------------------------- | ------------------------ | ---------------- |
| add    | hostname:string,sha:string | CertificatePinnerBuilder | 添加证书锁定参数 |
| build  | NA                         | CertificatePinner        | 构造证书锁定实例 |



## 约束与限制

在下述版本验证通过：

- DevEco Studio: NEXT Beta1-5.0.3.806, SDK:API12 Release(5.0.0.66)
- DevEco Studio 版本： 4.1 Canary(4.1.3.317), OpenHarmony SDK: API11 (4.1.0.36)
- DevEco Studio 版本： 4.1 Canary(4.1.3.319), OpenHarmony SDK: API11 (4.1.3.1)
- DevEco Studio 版本： 4.1 Canary(4.1.3.500), OpenHarmony SDK: API11 (4.1.5.6)

## 目录结构

```javascript
|---- httpclient  
|     |---- entry  # 示例代码文件夹
|     |---- library  # httpclient 库文件夹
			|---- builders  # 请求体构建者模块 主要用于构建不同类型的请求体，例如文件上传，multipart
            |---- cache  # 缓存的事件数据操作模块
			|---- callback  # 响应回调模块，用于将相应结果解析之后转换为常见的几种类型回调给调用者，例如string,JSON对象，bytestring
            |---- code  # 响应码模块，服务器返回的响应结果码
            |---- connection  # 路由模块，管理请求中的多路由
            |---- cookies  # cookie管理模块，主要处理将响应结果解析并根据设置的缓存策略缓存响应头里面的cookie，取出cookie，更新cookie
            |---- core  # 核心模块，主要是从封装的request里面解析请求参数和相应结果，调用拦截器，处理错误重试和重定向，dns解析，调用系统的@ohos.net.http模块发起请求
			|---- dispatcher  # 任务管理器模块，用于处理同步和异步任务队列
			|---- http  # 判断http method类型
			|---- interceptor  # 拦截器模块，链式拦截器处理网络请求
			|---- protocols  # 支持的协议
			|---- response  # 响应结果模块，用于接收服务端返回的结果
			|---- utils  # 工具类，提供dns解析，gzip解压缩，文件名校验，打印日志，获取URL的域名或者IP，双端队列等功能
            |---- HttpCall.ts  # 一个请求任务，分为同步请求和异步请求，封装了请求参数，请求客户端，请求成功和失败的回调，请求是否取消的标志。
            |---- HttpClient.ts  # 请求客户端，用于生成请求任务用于发起请求，设置请求参数，处理gzip解压缩，取消请求。
            |---- Interceptor.ts  # 拦截器接口
			|---- Request.ts  # 请求对象，用于封装请求信息，包含请求头和请求体。 
            |---- RequestBody.ts  # 请求体，用于封装请求体信息。
            |---- WebSocket.ts  # websocket模块回调接口。 
            |---- RealWebSocket.ts  # websocket模块，用于提供websocket支持。 
            |---- WebSocketListener.ts  # websocket状态监听器。 
            |---- Dns.ts  # 用于自定义自定义DNS解析器。 
            |---- CertificatePinner.ts  # 证书锁定类构建器。
            |---- DnsSystem.ts  # 系统默认DNS解析器。 
            |---- Route.ts  # 路由。 
            |---- RouteSelector.ts  # 路由选择器。 
            |---- Address.ts  # 请求地址。 
            |---- authenticator  # 身份认证模块，用于提供网络请求401之后身份认证。 
            |---- tls  # 证书校验模块，用于tls的证书解析和校验。 
            |---- enum  # 参数对应的枚举类型。 
            |---- index.ts  # httpclient对外接口
|     |---- README.MD  # 安装使用方法                   
```

## 贡献代码

使用过程中发现任何问题都可以提[Issue](https://gitee.com/openharmony-tpc/httpclient/issues) 给我们，当然，我们也非常欢迎你给我们提[PR](https://gitee.com/openharmony-tpc/httpclient/pulls)。

## 开源协议

本项目基于 [Apache License 2.0](https://gitee.com/openharmony-tpc/httpclient/blob/master/LICENSE)，请自由地享受和参与开源。
