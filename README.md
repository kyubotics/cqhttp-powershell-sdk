# CQHTTP PowerShell SDK

使用 PowerShell 开发 CQHTTP 应用，**目前同一时间只能处理一条消息，请只使用本 SDK 做测试或娱乐用途，不要用于严肃的生产环境**。

## 安装

如果你的操作系统是 Windows 10、Windows Server 2016 或更高版本，或安装了 PowerShell 6，或手动安装了 [PowerShellGet](https://docs.microsoft.com/zh-cn/powershell/gallery/overview) 模块，可以运行下面命令安装或更新本 SDK：

```ps1
Install-Module -Name CQHttp -Scope CurrentUser # 安装
Update-Module -Name CQHttp # 更新
```

如果不想安装到系统模块中，也可以直接克隆本项目并仿照 demo 编写代码。

## 使用

安装 `CQHttp` 模块后，直接在 PowerShell 运行下面命令即可启动一个最简单的 bot：

```ps1
Invoke-CQHttpBot `
    -ApiRoot "http://127.0.0.1:5700" `
    -Address "127.0.0.1:8080" `
    -EventCallbacks @(,@("", { param($Bot, $Ctx) echo ($Ctx | ConvertTo-Json) }))
```

上面的命令会把收到的事件全部以 JSON 形式打印出来。其中，`-Address` 参数，如果要使用所有 IP，需要传入 `+:8080`。

注意，运行之后无法通过 Ctrl-C 停止，只能直接关闭控制台。

更多使用方法见 [Demo.ps1](Demo.ps1)。

## 兼容性

理论上支持 PowerShell 3.0+，目前在下面环境测试过：

- Linux, PowerShell Core 6.1.1
- Windows 10, PowerShell Desktop 5.1.18312.1001
