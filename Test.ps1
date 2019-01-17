Import-Module ./CQHttp

$bot = New-CQHttp -ApiRoot "http://192.168.69.128:5700"

$bot.Run("+:8080")
# $bot.Run()
