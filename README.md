# native-js-hug 原生应用于JS交互

### html使用样例
[https://github.com/mrxir/native-js-hug/blob/master/native-js-hug/index.html](https://github.com/mrxir/native-js-hug/blob/master/native-js-hug/index.html)

## API说明

* 此函数为js中触发获取工号的事件，oc不规定此函数的命名规则，oc只约定 expression 的数据结构，例如 tt.getUserCode 就是用来获取工号的，这个是双方约定好的。

```

function didClickButtonGetUserCode(){
    var expression =
    {
        "method": "tt.getUserCode", // 必须写成 "method"，冒号右边的内容是双方约定好的
        "completion": "completionForDidClickButtonGetUserCode" // 必须写成 "completion"，冒号右边的内容是在本次js调用oc时临时约定的，oc会通过约定的函数去调用js，用以返回数据
    };
    window.webkit.messageHandlers.performAppleSelector.postMessage(expression);
}

```
        
* 与function didClickButtonGetUserCode()成对存在

```

function completionForDidClickButtonGetUserCode(response){
    
    // 在此处处理你的逻辑，预期的 response 结构为 {"message":"工号获取成功","data":"BMW-AK47","code":"200"}
    // ======>>>>>
    // code here
    // ======<<<<<
    
    var obj = response;
    
    // ======>>>>> 以下内容通常是可选的，但在双方联调解决错误时是必要的
    // 如果js在response获得了任何结果，需要报告给oc，以便于oc明确知晓本次交互过程是否完整
    // 举例
    // if code == 200 window.webkit.messageHandlers.reportPerformResult.postMessage('js报告工号获取成功');
    // if code != 200 window.webkit.messageHandlers.reportPerformResult.postMessage('js报告工号获取失败');
    // reportPerformResult('你想要报告的内容');
    var report =
    {
        "method": "reportPerformReponse", // 必须写成 "method"，冒号右边的内容是双方约定好的
        "report_method": "tt.getUserCode",
        "report_object": response  // 必须写成 "completion"，冒号右边的内容是在本次js调用oc时临时约定的，oc会通过约定的函数去调用js，用以返回数据
    };
    reportPerformReponse(report);
    // ======<<<<< 以上内容通常可是可选的，但在双方联调解决错误时是必要的
    
}

```

* 可选，此函数用于JS向OC报告是否获取到预期的结果

```

function reportPerformReponse(report){
    window.webkit.messageHandlers.reportPerformReponse.postMessage(report);
}

```

