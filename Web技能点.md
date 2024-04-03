# Web技能点

## from: HeDong-Gong

## 一、网页公网挂载及SSL证书申请

- <https://free.3v.do>可申请免费空间（1000M）及域名->无SSL
- 使用CuteFTP软件可快速将网页上传至服务器
  - 参考：[黑马程序员-申请免费空间及网页上传](https://www.bilibili.com/video/BV14J4114768?p=355&vd_source=342eccbc4d465bf497998654ef8f8018)
- github仓库设置页的page选项可将指定分支的index.html变为公网网页（域名：<仓库名>.github.io）->https
- github提供了自定义域名的选项，可绑定自己的国外域名，但SSL证书需要自己申请，操作如下：
  1. 注册域名：<https://www.namesilo.com>，低价，国外域名
  2. 在域名的Manager DNS页面中添加A记录（推荐，可减少重定向次数）或者CNAME
     - DNS的IPV4地址如下：
       - 185.199.108.153
       - 185.199.109.153
       - 185.199.110.153
       - 185.199.111.153
  3. 生成SSL：<https://dash.cloudflare.com/>，将域名添加到cloudflare的管控下，你会获得两个cloudflare服务商域名。需注意如下几点：
     1. 需要在域名注册商处将NameSevers修改为你的得到的服务商域名，使流量流经cloudflare
     2. 成功加入管制后需进入SSL设置页将SSL状态由灵活改为全面（解决重定向次数过多导致网页无法访问的问题）
     3. 进入页面规则页设置始终使用https（让你的网站更安全，并解决输入域名默认http访问的情况）
  4. 将域名添加到github的自定义域名项，等待审核（需数小时，可能会报错，不用管）
  5. 勾选Enforce https
  - 参考：[知乎-Github部署个人网页|自定义域](https://zhuanlan.zhihu.com/p/393050270#:~:text=Github%20%E5%B0%B1%E5%BE%88%E7%AE%80%E5%8D%95%E4%BA%86%EF%BC%8C%E9%A6%96%E5%85%88%E5%9C%A8%20Settings%20%E5%A4%84%E5%A1%AB%E5%85%A5%E5%88%9A%E5%88%9A%E8%B4%AD%E4%B9%B0%E7%9A%84%E4%B8%AA%E4%BA%BA%E5%9F%9F%E5%90%8D%E3%80%82%20%E7%84%B6%E5%90%8E%E6%8B%89%E5%88%B0%E4%B8%8B%E9%9D%A2%EF%BC%8C%E7%82%B9%E5%87%BB%20Check%20it,out%20here%21%20%E5%9C%A8%E9%87%8C%E9%9D%A2%E7%9A%84%20Custom%20Domain%20%E9%87%8C%E5%A1%AB%E4%BD%A0%E7%9A%84%E5%9F%9F%E5%90%8D%EF%BC%8C%E5%B9%B6%E7%82%B9%E5%BC%80%20Enforce%20HTTPS%E3%80%82)

## 下述两个尝试旨在实现内网的https访问

### 为什么我要这样做？

1. 服务器的直接挂载因网速原因无法满足我们对帧率的要求，因此我们使用本机作为服务器，从而由公网转向了内网
2. flask运行会生成局域网IP，为http
3. 只有安全的https或信任的http才能调用用户设备，我希望直接将http变成https来省去信任的步骤

## 二、内网穿透

- 使用ngrok：<https://dashboard.ngrok.com/>，免费，下载并指定本地端口进行穿透->https，静动态域名，不可自定义
- 使用NATAPP（不推荐，Flask通信出错）：<https://natapp.cn/>，有免费和付费通道。免费通道只支持http，付费通道可购买具有SSL证书的自定义域名
  - 官方入门教程：[NATAPP快速开始](https://natapp.cn/article/natapp_newbie)

## 三、自签名SSL

- 制作自签SSL
  1. 安装openssl[Windows64/32 openssl便捷安装包](https://slproweb.com/products/Win32OpenSSL.html)
     - 参考：[CSDN-Windows安装openssl](https://blog.csdn.net/wuliang20/article/details/121014060?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522171003269216800225561016%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=171003269216800225561016&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~top_click~default-1-121014060-null-null.142^v99^pc_search_result_base9&utm_term=openssl%20windows&spm=1018.2226.3001.4187)
  2. 生成自签名证书
     - 参考：[CSDN-在Flask中使用HTTPS](https://blog.csdn.net/yannanxiu/article/details/70672744)

- 使用flask工具及cryptography包实现自签名SSL
  1. 安装cryptography包
     ```bash
     pip install -i https://pypi.tuna.tsinghua.edu.cn/simple cryptography
     ```
  2. flask运行时指定ssl_context参数为'adhoc'
     ```markdown
     app.run(ssl_context='adhoc')
     ```
  - 缺点：找不到自签名证书位置，无法将其添加至浏览器信任列表
- 注意：
  - 浏览器大多把自签名SSL生成的https视为危险，需在浏览器设置的证书管理栏信任CA证书
  - 未信任时，自签SSL在本地端口的https访问可在用户手动确认后访问到用户设备，但在其他情况浏览器会直接拒绝站点访问

### 终局：Failure，网速有限，仍无法满足智慧拍照300fp帧率的要求

## 四、https域名访问后端程序

- 步骤
  1. 在cloudflare服务商处为域名增加流量管控及SSL加密  
  链接：<https://dash.cloudflare.com/>
  2. flask后端使用服务商SSL证书（阿里云）生成https服务，端口443
  3. 使用域名发起https访问，成功，无连接安全警告

- 局限

  1. 这样的做法形式上达到了目的，但由于流量加密及cloudflare服务商远在美国，网速不理想（环境识别语音播报约有10s额外延时）。  
  我们明白了不须DNS解析的IP访问才是最迅速的
  2. 需使用港澳台或境外服务器避免域名备案难关，成本高，难较长期维持

### 我们最后放弃了这个方案

## 五、https公网IP访问后端程序

- 实现方法

  1. 注册国内域名并申请SSL证书，下载证书（pem\key格式）
  2. 在flask的app.run()或soketio.run()中添加ssl_context=('path/to/YOUR_PEM.pem', 'path/to/YOUR_KEY.key')
  3. 指定端口为443
  4. 浏览器使用https访问公网IP，成功，虽然仍存在连接风险警告

- 一些探索

  1. 这里的SSL证书如果使用自签名证书或本机证书来代替服务商证书（如阿里云SSL）则会导致部分浏览器无法访问IP（在Android版Edge上失败），可能是加密方式的原因
  2. 这里没有将证书加入到IIS服务器中，而是直接用flask调取，坏处是没法使用域名访问， 好处是解决了端口占用的问题
  3. 我当时用的是香港服务器，在作了上述配置后，我希望用域名通过https访问后端程序，具体是：https://pineapplesnowy.top，但失败。  
  我又试着将后端端口换为80，并用域名访问，具体是：https://pineapplesnowy.top:80。失败。  
  但是当我将后端换为http时获得了成功。  
  此前我已经在服务器商处放行了443 80 5000端口，不是安全组的问题

### 上述方案该为我们最终采取
